defmodule Orsimer.RLE.Byte do

  def encode(bytes) do
    length = - byte_size(bytes)
    <<length::integer-signed-size(8)>> <> bytes
  end
end
