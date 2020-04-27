defmodule Orsimer.RLEv2.Integer.Delta do
  @spec encode([integer()], boolean) :: {binary, [integer()]}
  def encode(integers, signed? \\ false) do
    deltas =
      Enum.chunk_every(integers, 2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    width = Orsimer.Helper.minimum_bits(deltas)
    encoded_width = Orsimer.RLEv2.FiveBit.encode(width)
    length = length(deltas)

    base_value = List.first(integers) |> encode_varint(signed?)
    delta_base = List.first(deltas) |> encode_varint(true)

    binary =
      case all_same?(deltas) do
        true ->
          build_header(0, length) <> base_value <> delta_base

        false ->
          deltas
          |> Enum.drop(1)
          |> Enum.reduce(
            build_header(encoded_width, length) <> base_value <> delta_base,
            fn delta, acc ->
              delta_abs = abs(delta)
              <<acc::bitstring, delta_abs::size(width)>>
            end
          )
      end

    Orsimer.Helper.pad_to_binary(binary)
  end

  @spec decode(binary(), boolean()) :: {[integer()], binary}
  def decode(<<3::size(2), width::size(5), length::size(9), data::binary>>, signed? \\ false) do
    decoded_width = Orsimer.RLEv2.FiveBit.decode(width)

    {base_value, rest} = varint(data, signed?)
    {delta_base, rest} = varint(rest, true)

    case width == 0 do
      true ->
        integers =
          Enum.reduce(1..length, [base_value], fn _, [prev | _] = acc ->
            [prev + delta_base | acc]
          end)
          |> Enum.reverse()

        {integers, rest}

      false ->
        sign = if delta_base >= 0, do: 1, else: -1
        bytes_to_read = Orsimer.Helper.bit_size_to_byte_size(decoded_width * (length - 1))
        <<bytes::binary-size(bytes_to_read), remaining::binary>> = rest

        deltas = [delta_base] ++ get_deltas(bytes, decoded_width, length - 1, sign)

        integers =
          Enum.reduce(deltas, [base_value], fn delta, [prev | _] = acc ->
            [prev + delta | acc]
          end)
          |> Enum.reverse()

        {integers, remaining}
    end
  end

  defp build_header(width, length) do
    <<3::size(2), width::size(5), length::size(9)>>
  end

  defp all_same?(list) do
    first = List.first(list)
    Enum.all?(list, fn element -> element == first end)
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
