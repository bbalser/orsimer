defmodule Orsimer.RLE.Boolean do
  @max_values 1024

  @spec encode([boolean()]) :: binary
  def encode(list) when length(list) > @max_values do
    raise "Unable to encode more than 1024 booleans"
  end

  def encode(list) do
    bits =
      Enum.reduce(list, <<>>, fn
        true, acc -> <<acc::bitstring, 1::size(1)>>
        false, acc -> <<acc::bitstring, 0::size(1)>>
      end)

    binary = Orsimer.Helper.pad_to_binary(bits)
    length = -byte_size(binary)

    <<length::integer-signed-size(8)>> <> binary
  end

  @spec decode(binary) :: {[boolean], binary}
  def decode(binary) do
    {data, remaining} = Orsimer.RLE.Byte.decode(binary)

    booleans =
      Stream.unfold(data, fn
        <<>> -> nil
        <<1::size(1), rest::bitstring>> -> {true, rest}
        <<0::size(1), rest::bitstring>> -> {false, rest}
      end)
      |> Enum.to_list()

    {booleans, remaining}
  end
end
