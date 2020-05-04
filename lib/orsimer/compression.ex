defmodule Orsimer.Compression do
  #TODO only create compressed chunk up to compressed block size
  def compress(input) do
    compressed_data = Orsimer.Compression.Zlib.zip(input)
    compressed_byte_size = byte_size(compressed_data)
    original_byte_size = byte_size(input)

    case compressed_byte_size < original_byte_size do
      true ->
        <<compressed_byte_size * 2::size(24)-little>> <> compressed_data

      false ->
        <<original_byte_size * 2 + 1::size(24)-little>> <> input
    end
  end

  def decompress(compressed, buffer \\ <<>>)

  def decompress(<<>>, buffer), do: buffer

  def decompress(<<_::size(7), 1::size(1), _::binary>> = binary, buffer) do
    <<header::size(24)-little, body::binary>> = binary

    length = div(header-1, 2)
    <<original::binary-size(length), remaining::binary>> = body
    decompress(remaining, buffer <> original)
  end

  def decompress(<<header::size(24)-little, body::binary>>, buffer) do
    length = div(header, 2)

    <<compressed::binary-size(length), remaining::binary>> = body

    decompress(remaining, buffer <> Orsimer.Compression.Zlib.unzip(compressed))
  end
end
