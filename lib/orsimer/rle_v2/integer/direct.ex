defmodule Orsimer.RLEv2.Integer.Direct do
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

    Enum.reduce(integers, header, fn int, acc ->
      acc <> <<int::size(width)>>
    end)
  end

  def decode(<<1::size(2), width::size(5), _length::size(9), data::bitstring>>, signed? \\ false) do
    decoded_width = Orsimer.RLEv2.FiveBit.decode(width)

    stream =
      Stream.unfold(data, fn
        <<>> -> nil
        <<value::size(decoded_width), rest::bitstring>> -> {value, rest}
      end)

    case signed? do
      true -> Enum.map(stream, &Varint.Zigzag.decode/1)
      false -> Enum.to_list(stream)
    end
  end
end
