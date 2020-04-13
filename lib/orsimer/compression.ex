defmodule Orsimer.Compression do
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

  def decompress(<<_::size(7), 1::size(1), _::size(16), body::binary>>) do
    body
  end

  def decompress(<<_header::size(24), body::binary>>) do
    Orsimer.Compression.Zlib.unzip(body)
  end
end
