defmodule Orsimer.RLEv2.Integer.Delta do
  def encode(integers, signed? \\ false) do
    deltas =
      Enum.chunk_every(integers, 2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    width = Orsimer.Helper.minimum_bits(deltas)
    encoded_width = Orsimer.RLEv2.FiveBit.encode(width)

    length = length(deltas)

    header = <<3::size(2), encoded_width::size(5), length::size(9)>>

    base_value = integers |> List.first() |> encode_varint(signed?)
    delta_base = deltas |> List.first() |> encode_varint(true)

    deltas
    |> Enum.drop(1)
    |> Enum.reduce(header <> base_value <> delta_base, fn delta, acc ->
      delta_abs = abs(delta)
      <<acc::bitstring, delta_abs::size(width)>>
    end)
  end

  def decode(<<3::size(2), width::size(5), _length::size(9), data::bitstring>>, signed? \\ false) do
    decoded_width = Orsimer.RLEv2.FiveBit.decode(width)

    {base_value, rest} = varint(data, signed?)
    {delta_base, rest} = varint(rest, true)

    sign = if delta_base >= 0, do: 1, else: -1

    deltas =
      [delta_base] ++
        (Stream.unfold(rest, fn
           <<>> -> nil
           <<delta::size(decoded_width), remaining::bitstring>> -> {delta * sign, remaining}
         end)
         |> Enum.to_list())

    Enum.reduce(deltas, [base_value], fn delta, [prev | _] = acc ->
      [prev + delta | acc]
    end)
    |> Enum.reverse()
  end

  defp encode_varint(integer, signed?) do
    case signed? do
      true -> Varint.Zigzag.encode(integer) |> Varint.LEB128.encode()
      false -> Varint.LEB128.encode(integer)
    end
  end

  defp varint(binary, signed?) do
    {value, rest} = Varint.LEB128.decode(binary)

    case signed? do
      true -> {Varint.Zigzag.decode(value), rest}
      false -> {value, rest}
    end
  end
end
