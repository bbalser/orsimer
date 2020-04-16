defmodule Orsimer.RLEv2.Integer.Delta do
  def encode(integers, signed? \\ false) do
    {integers_to_encode, remaining} = Enum.split(integers, 512)

    deltas =
      Enum.chunk_every(integers_to_encode, 2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    width = Orsimer.Helper.minimum_bits(deltas)
    encoded_width = Orsimer.RLEv2.FiveBit.encode(width)

    length = length(deltas)

    header = <<3::size(2), encoded_width::size(5), length::size(9)>>

    base_value = integers |> List.first() |> encode_varint(signed?)
    delta_base = deltas |> List.first() |> encode_varint(true)

    binary =
      deltas
      |> Enum.drop(1)
      |> Enum.reduce(header <> base_value <> delta_base, fn delta, acc ->
        delta_abs = abs(delta)
        <<acc::bitstring, delta_abs::size(width)>>
      end)

    {Orsimer.Helper.pad_to_binary(binary), remaining}
  end

  def decode(<<3::size(2), width::size(5), length::size(9), data::binary>>, signed? \\ false) do
    decoded_width = Orsimer.RLEv2.FiveBit.decode(width)
    length = length + 1

    {base_value, rest} = varint(data, signed?)
    {delta_base, rest} = varint(rest, true)

    bytes_to_read = Orsimer.Helper.bit_size_to_byte_size(decoded_width * (length - 2))
    <<bytes::binary-size(bytes_to_read), remaining::binary>> = rest

    sign = if delta_base >= 0, do: 1, else: -1
    deltas = [delta_base] ++ get_deltas(bytes, decoded_width, length - 2, sign)

    integers =
      Enum.reduce(deltas, [base_value], fn delta, [prev | _] = acc ->
        [prev + delta | acc]
      end)
      |> Enum.reverse()

    {integers, remaining}
  end

  defp get_deltas(binary, width, count, sign) do
    {values, _} =
      Enum.map_reduce(1..count, binary, fn _, acc ->
        <<delta::size(width), rest::bitstring>> = acc
        {delta * sign, rest}
      end)

    values
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
