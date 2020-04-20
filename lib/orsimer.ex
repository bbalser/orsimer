defmodule Orsimer do
  @type stream_kind :: :ROW_INDEX | :PRESENT | :LENGTH | :DATA
  @type stream :: binary

  @type streams :: [{stream_kind, stream}]

  def write(schema, data) do
    streams = Orsimer.Type.streams(schema, data)

    stripe_footer =
      Orc.Proto.StripeFooter.new(
        columns: Orsimer.Type.column_encoding(schema),
        streams: Enum.map(streams, fn {s, _b} -> s end)
      )
      |> Orc.Proto.StripeFooter.encode()
      |> Orsimer.Compression.compress()

    index_streams =
      streams
      |> Enum.filter(fn {s, _b} -> s.kind == :ROW_INDEX end)
      |> Enum.map(fn {_s, b} -> b end)
      |> Enum.join()

    data_streams =
      streams
      |> Enum.reject(fn {s, _b} -> s.kind == :ROW_INDEX end)
      |> Enum.map(fn {_s, b} -> b end)
      |> Enum.join()

    stripe =
      Orc.Proto.StripeInformation.new(
        indexLength: byte_size(index_streams),
        dataLength: byte_size(data_streams),
        footerLength: byte_size(stripe_footer),
        numberOfRows: length(data),
        offset: 3
      )

    footer =
      Orc.Proto.Footer.new(
        numberOfRows: length(data),
        rowIndexStride: 10_000,
        metadata: [],
        statistics: [],
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
        metadataLengt: 0,
        version: [0, 12],
        writerVersion: 1
      )
      |> Orc.Proto.PostScript.encode()

    "ORC" <>
      index_streams <>
      data_streams <>
      stripe_footer <>
      footer <>
      postscript <>
      <<byte_size(postscript)::size(8)>>
  end

  def to_bits(binary, list \\ [])

  def to_bits(<<>>, list) do
    Enum.reverse(list)
  end

  def to_bits(<<bit::size(1), rest::bitstring>>, list) do
    to_bits(rest, [bit | list])
  end
end
