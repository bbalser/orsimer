defmodule Orsimer.RLEv2.Integer.Direct do
  @spec encode([integer()], boolean) :: {binary, [integer()]}
  def encode(input, signed? \\ false) do
    integers =
      case signed? do
        true -> Enum.map(input, &Varint.Zigzag.encode/1)
        false -> input
      end

    width = Orsimer.Helper.minimum_bits(integers)
    encoded_width = Orsimer.RLEv2.FiveBit.encode(width)

    length = length(integers) - 1

    header = <<1::size(2), encoded_width::size(5), length::size(9)>>

    bits =
      Enum.reduce(integers, header, fn int, acc ->
        <<acc::bitstring, int::size(width)>>
      end)

    Orsimer.Helper.pad_to_binary(bits)
  end

  @spec decode(binary(), boolean()) :: {[integer()], binary}
  def decode(<<1::size(2), width::size(5), length::size(9), data::bitstring>>, signed? \\ false) do
    decoded_width = Orsimer.RLEv2.FiveBit.decode(width)
    length = length + 1

    bytes_to_read = Orsimer.Helper.bit_size_to_byte_size(decoded_width * length)
    <<bytes::binary-size(bytes_to_read), remaining::binary>> = data

    {values, _} =
      Enum.map_reduce(1..length, bytes, fn _, bytes ->
        <<value::size(decoded_width), rest::bitstring>> = bytes
        {value, rest}
      end)

    case signed? do
      true -> {Enum.map(values, &Varint.Zigzag.decode/1), remaining}
      false -> {values, remaining}
    end
  end
end
