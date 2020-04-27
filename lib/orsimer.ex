defmodule Orsimer do
  @type stream_kind :: :DATA | :LENGTH | :PRESENT
  @type uncompressed_binary_stream :: binary
  @type compressed_binary_stream :: binary
  @type streams :: [{Orc.Proto.Stream.t(), compressed_binary_stream()}]

  def write(schema, data) do
    results = Orsimer.Encoder.encode(schema, data)
    {index_streams, index_binary} = create_index_streams(results)
    {data_streams, data_binary} = create_data_streams(results)

    stripe_footer =
      Orc.Proto.StripeFooter.new(
        columns: Orsimer.Type.column_encoding(schema),
        streams: Enum.reverse(index_streams) ++ Enum.reverse(data_streams)
      )
      |> Orc.Proto.StripeFooter.encode()
      |> Orsimer.Compression.compress()

    stripe =
      Orc.Proto.StripeInformation.new(
        indexLength: byte_size(index_binary),
        dataLength: byte_size(data_binary),
        footerLength: byte_size(stripe_footer),
        numberOfRows: length(data),
        offset: 3
      )

    metadata =
      Orc.Proto.Metadata.new(
        stripeStats: [
          Orc.Proto.StripeStatistics.new(colStats: Orsimer.Statistics.calculate(schema, data))
        ]
      )
      |> Orc.Proto.Metadata.encode()
      |> Orsimer.Compression.compress()

    footer =
      Orc.Proto.Footer.new(
        numberOfRows: length(data),
        rowIndexStride: 10_000,
        metadata: [],
        statistics: Orsimer.Statistics.calculate(schema, data),
        stripes: [stripe],
        types: Orsimer.Type.to_list(schema)
      )
      |> Orc.Proto.Footer.encode()
      |> Orsimer.Compression.compress()

    postscript =
      Orc.Proto.PostScript.new(
        compression: :ZLIB,
        compressionBlockSize: 262_144,
        footerLength: byte_size(footer),
        metadataLength: byte_size(metadata),
        version: [0, 12],
        writerVersion: 1
      )
      |> Orc.Proto.PostScript.encode()

    "ORC" <>
      index_binary <>
      data_binary <>
      stripe_footer <>
      metadata <>
      footer <>
      postscript <>
      <<byte_size(postscript)::size(8)>>
  end

  defp create_index_streams(results) do
    results
    |> Enum.reduce({[], <<>>}, fn result, {streams, binary} ->
      compressed_binary =
        result.index
        |> Orc.Proto.RowIndex.encode()
        |> Orsimer.Compression.compress()

      stream =
        Orc.Proto.Stream.new(
          column: result.column,
          kind: :ROW_INDEX,
          length: byte_size(compressed_binary)
        )

      {[stream | streams], binary <> compressed_binary}
    end)
  end

  defp create_data_streams(results) do
    results
    |> Enum.map(fn result -> Enum.zip(Stream.cycle([result.column]), result.data_streams) end)
    |> List.flatten()
    |> Enum.reduce({[], <<>>}, fn {column, {kind, bin}}, {streams, binary} ->
      compressed_binary = Orsimer.Compression.compress(bin)

      stream =
        Orc.Proto.Stream.new(column: column, kind: kind, length: byte_size(compressed_binary))

      {[stream | streams], binary <> compressed_binary}
    end)
  end

  def to_bits(binary, list \\ [])

  def to_bits(<<>>, list) do
    Enum.reverse(list)
  end

  def to_bits(<<bit::size(1), rest::bitstring>>, list) do
    to_bits(rest, [bit | list])
  end
end
