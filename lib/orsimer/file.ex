defmodule Orsimer.File.Stripe do
  defstruct [:footer, :data, :indexes]

  def parse(stripe_bytes, %Orc.Proto.StripeInformation{} = stripe) do
    footer =
      binary_part(stripe_bytes, stripe.indexLength + stripe.dataLength, stripe.footerLength)
      |> Orsimer.Compression.decompress()
      |> Orc.Proto.StripeFooter.decode()

    {index_streams, data_streams} =
      Enum.split_with(footer.streams, fn s -> s.kind == :ROW_INDEX end)

    {indexes, rest} =
      Enum.map_reduce(index_streams, stripe_bytes, fn stream, bytes ->
        length = stream.length
        <<index_bytes::binary-size(length), remaining::binary>> = bytes

        row_index =
          index_bytes
          |> Orsimer.Compression.decompress()
          |> Orc.Proto.RowIndex.decode()

        {{stream.column, row_index}, remaining}
      end)

    {data, _rest} =
      Enum.map_reduce(data_streams, rest, fn stream, bytes ->
        length = stream.length
        IO.inspect(stream.length, label: "data stream length")
        <<data_bytes::binary-size(length), remaining::binary>> = bytes
        {{stream.column, Orsimer.Compression.decompress(data_bytes)}, remaining}
      end)

    %__MODULE__{
      footer: footer,
      indexes: Map.new(indexes),
      data: Map.new(data)
    }
  end
end

defmodule Orsimer.File do
  defstruct [:postscript, :footer, :stripes]

  def read(file) do
    file = File.read!(file)
    "ORC" = binary_part(file, 0, 3)

    file_size = byte_size(file)
    <<postscript_size>> = binary_part(file, file_size - 1, 1)

    postscript =
      binary_part(file, file_size - 1 - postscript_size, postscript_size)
      |> Orc.Proto.PostScript.decode()

    footer =
      binary_part(
        file,
        file_size - 1 - postscript_size - postscript.footerLength,
        postscript.footerLength
      )
      |> Orsimer.Compression.decompress()
      |> Orc.Proto.Footer.decode()

    stripes =
      Enum.map(footer.stripes, fn stripe ->
        length = stripe.indexLength + stripe.dataLength + stripe.footerLength
        bytes = binary_part(file, stripe.offset, length)

        Orsimer.File.Stripe.parse(bytes, stripe)
      end)

    %__MODULE__{
      postscript: postscript,
      footer: footer,
      stripes: stripes
    }
  end
end
