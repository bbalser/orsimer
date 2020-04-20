defmodule Orsimer.RLEv2.Integer do
  alias Orsimer.RLEv2.Integer.{Delta, Direct}
  @behaviour Orsimer.Encoder
  @behaviour Orsimer.Decoder

  defmodule Row do
    defstruct positions: [0, 0, 0],
              stats: Orc.Proto.IntegerStatistics.new(minimum: nil, maximum: nil, sum: 0),
              binary: <<>>,
              values: 0
  end

  @chunk_size 512
  @row_size 10_000

  @impl Orsimer.Encoder
  def encode(integers, opts \\ []) do
    signed? = Keyword.get(opts, :signed?, false)

    rows =
      integers
      |> Enum.chunk_every(@chunk_size)
      |> encode_chunks(signed?, 0, [%Row{}])

    binary =
      rows
      |> Enum.map(&Map.get(&1, :binary))
      |> Enum.join()

    indexes =
      rows
      |> Enum.map(fn row ->
        Orc.Proto.RowIndexEntry.new(
          positions: row.positions,
          statistics:
            Orc.Proto.ColumnStatistics.new(
              numberOfValues: row.values,
              hasNull: false,
              intStatistics: row.stats
            )
        )
      end)

    index = Orc.Proto.RowIndex.new(entry: indexes)

    {index, [{:DATA, binary}]}
  end

  defp encode_chunks([], _signed?, _count, rows), do: Enum.reverse(rows)

  defp encode_chunks([chunk | tail], signed?, count, [previous_row | rows])
       when count + length(chunk) > @row_size do
    to_consume = @row_size - count
    new_count = length(chunk) - to_consume

    [_, previous_start, _] = previous_row.positions
    new_start = previous_start + byte_size(previous_row.binary)

    {prev_numbers, next_numbers} = Enum.split(chunk, to_consume)
    previous_row =
      previous_row
      |> update_stats(prev_numbers)
      |> update_count_of_values(to_consume)

    new_row =
      %Row{positions: [0, new_start, to_consume]}
      |> update_binary(chunk, signed?)
      |> update_stats(next_numbers)
      |> update_count_of_values(new_count)

    encode_chunks(tail, signed?, new_count, [new_row, previous_row | rows])
  end

  defp encode_chunks([chunk | tail], signed?, count, [row | rows]) do
    length = length(chunk)
    new_count = count + length

    new_row =
      row
      |> update_stats(chunk)
      |> update_binary(chunk, signed?)
      |> update_count_of_values(length)

    encode_chunks(tail, signed?, new_count, [new_row | rows])
  end

  @impl Orsimer.Decoder
  def decode([{:DATA, data_stream}], opts \\ []) do
    signed? = Keyword.get(opts, :signed?, false)
    do_decode(data_stream, signed?, [])
  end

  defp do_decode(<<>>, _signed?, buffer), do: List.flatten(buffer)

  defp do_decode(<<1::size(2), _::bitstring>> = binary, signed?, buffer) do
    {integers, remaining} = Direct.decode(binary, signed?)
    do_decode(remaining, signed?, [buffer | integers])
  end

  defp do_decode(<<3::size(2), _::bitstring>> = binary, signed?, buffer) do
    {integers, remaining} = Delta.decode(binary, signed?)
    do_decode(remaining, signed?, [buffer | integers])
  end

  defp update_stats(%Row{} = row, integers) do
    Map.update!(row, :stats, fn stats ->
      %{
        stats
        | minimum: safe_min(stats.minimum, integers),
          maximum: safe_max(stats.maximum, integers),
          sum: stats.sum + Enum.sum(integers)
      }
    end)
  end

  defp safe_min(nil, []), do: nil
  defp safe_min(nil, list), do: Enum.min(list)
  defp safe_min(cur, []), do: cur
  defp safe_min(cur, list), do: min(cur, Enum.min(list))

  defp safe_max(nil, []), do: nil
  defp safe_max(nil, list), do: Enum.max(list)
  defp safe_max(cur, []), do: cur
  defp safe_max(cur, list), do: max(cur, Enum.max(list))

  defp update_binary(%Row{} = row, integers, signed?) do
    {binary, []} = Direct.encode(integers, signed?)

    %{row | binary: row.binary <> binary}
  end

  defp update_count_of_values(%Row{} = row, count) do
    %{row | values: row.values + count}
  end
end
