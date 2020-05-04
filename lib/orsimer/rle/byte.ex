defmodule Orsimer.RLE.Byte do
  @moduledoc """
  Run Length encoder for bytes

  Only encodes using literals

  Can decode either run or literal encoding

  Max values of 128 bytes can be stored in single chunk
  """

  def encode(bytes) do
    length = - byte_size(bytes)
    <<length::integer-signed-size(8)>> <> bytes
  end

  def decode(<<length::integer-signed-size(8), rest::binary>>) when length < 0 do
    length = - length
    <<data::binary-size(length), remaining::binary>> = rest
    {data, remaining}
  end

  def decode(<<length::integer-signed-size(8), repeated_byte::binary-size(1), remaining::binary>>) do
    data = Enum.reduce(1..(length + 3), <<>>, fn _, acc -> acc <> repeated_byte end)

    {data, remaining}
  end
end
