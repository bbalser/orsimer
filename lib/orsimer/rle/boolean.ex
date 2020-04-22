defmodule Orsimer.RLE.Boolean do
  @spec encode([boolean()]) :: binary
  def encode(list) do
    bits =
      Enum.reduce(list, <<>>, fn
        true, acc -> <<acc::bitstring, 1::size(1)>>
        false, acc -> <<acc::bitstring, 0::size(0)>>
      end)

    binary = Orsimer.Helper.pad_to_binary(bits)
    length = - byte_size(binary)

    <<length::integer-signed-size(8)>> <> binary
  end
end
