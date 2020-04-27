defimpl Orsimer.Encoder, for: Orsimer.Type.Integer do
  alias Orsimer.RLEv2.Integer.Direct

  @chunk_size 512
  @row_size 10_000

  def encode(t, list, opts \\ []) do
    column = Keyword.get(opts, :column, 0)
    signed? = Keyword.get(opts, :signed?, false)

    case Enum.any?(list, &is_nil/1) do
      false ->
        result =
          list
          |> Enum.chunk_every(@row_size)
          |> encode_chunks(%{binary: <<>>, leftover: [], entries: []}, t, signed?)

        %Orsimer.Encoder.Result{
          column: column,
          index: Orc.Proto.RowIndex.new(entry: Enum.reverse(result.entries)),
          data_streams: [DATA: result.binary]
        }

      true ->
        integers = Enum.reject(list, &is_nil/1)

        result =
          integers
          |> Enum.chunk_every(@row_size)
          |> encode_chunks(%{binary: <<>>, leftover: [], entries: []}, t, signed?)

        booleans =
          list
          |> Enum.map(&(not is_nil(&1)))

        [%{index: presence_index, data_streams: [{:DATA, presence_stream}]}] =
          Orsimer.Encoder.encode(Orsimer.Type.Boolean.new(), booleans)

        entries =
          result.entries
          |> Enum.reverse()
          |> Enum.zip(presence_index.entry)
          |> Enum.map(fn {int_index, bool_index} ->
            %{int_index | positions: bool_index.positions ++ int_index.positions}
          end)

        %Orsimer.Encoder.Result{
          column: column,
          index: Orc.Proto.RowIndex.new(entry: entries),
          data_streams: [PRESENT: presence_stream, DATA: result.binary]
        }
    end
    |> List.wrap()
  end

  defp encode_chunks([chunk], acc, type, signed?) do
    binary =
      (acc.leftover ++ chunk)
      |> Enum.chunk_every(@chunk_size)
      |> Enum.map(&Direct.encode(&1, signed?))
      |> Enum.join()

    entry =
      Orc.Proto.RowIndexEntry.new(
        positions: [0, byte_size(acc.binary), length(acc.leftover)],
        statistics: stats(type, chunk)
      )

    %{acc | leftover: [], binary: acc.binary <> binary, entries: [entry | acc.entries]}
  end

  defp encode_chunks([chunk | tail], acc, type, signed?) do
    need_to_encode = acc.leftover ++ chunk
    can_encode_count = div(length(need_to_encode), @chunk_size) * @chunk_size

    binary =
      need_to_encode
      |> Enum.take(can_encode_count)
      |> Enum.chunk_every(@chunk_size)
      |> Enum.map(&Direct.encode(&1, signed?))
      |> Enum.join()

    entry =
      Orc.Proto.RowIndexEntry.new(
        positions: [0, byte_size(acc.binary), length(acc.leftover)],
        statistics: stats(type, chunk)
      )

    new_acc = %{
      acc
      | leftover: Enum.drop(need_to_encode, can_encode_count),
        binary: acc.binary <> binary,
        entries: [entry | acc.entries]
    }

    encode_chunks(tail, new_acc, type, signed?)
  end

  defp stats(type, list) do
    [stats] = Orsimer.Statistics.calculate(type, list)
    stats
  end

  # defmodule Row do
  #   defstruct positions: [0, 0, 0],
  #     stats: Orc.Proto.IntegerStatistics.new(minimum: nil, maximum: nil, sum: 0),
  #     binary: <<>>,
  #     values: 0
  # end

  # def encode(_t, list, opts \\ []) do
  #   column = Keyword.get(opts, :column, 0)
  #   signed? = Keyword.get(opts, :signed?, false)

  #   # list = Enum.reject(list, fn i -> i == nil end)

  #   {index, streams} = encode_data(list, signed?)

  #   result = %Orsimer.Encoder.Result{
  #     column: column,
  #     index: index,
  #     data_streams: streams
  #   }

  #   [result]
  # end

  # defp encode_data(integers, signed?) do
  #   rows =
  #     integers
  #     |> Enum.chunk_every(@chunk_size)
  #     |> encode_chunks(signed?, 0, [%Row{}])

  #   binary =
  #     rows
  #     |> Enum.map(&Map.get(&1, :binary))
  #     |> Enum.join()

  #   indexes =
  #     rows
  #     |> Enum.map(fn row ->
  #       Orc.Proto.RowIndexEntry.new(
  #         positions: row.positions,
  #         statistics:
  #           Orc.Proto.ColumnStatistics.new(
  #             numberOfValues: row.values,
  #             hasNull: false,
  #             intStatistics: row.stats
  #           )
  #       )
  #     end)

  #   index = Orc.Proto.RowIndex.new(entry: indexes)

  #   {index, [{:DATA, binary}]}
  # end

  # defp encode_chunks([], _signed?, _count, rows), do: Enum.reverse(rows)

  # defp encode_chunks([chunk | tail], signed?, count, [previous_row | rows])
  #      when count + length(chunk) > @row_size do
  #   to_consume = @row_size - count
  #   new_count = length(chunk) - to_consume

  #   [_, previous_start, _] = previous_row.positions
  #   new_start = previous_start + byte_size(previous_row.binary)

  #   {prev_numbers, next_numbers} = Enum.split(chunk, to_consume)

  #   previous_row =
  #     previous_row
  #     |> update_stats(prev_numbers)
  #     |> update_count_of_values(to_consume)

  #   new_row =
  #     %Row{positions: [0, new_start, to_consume]}
  #     |> update_binary(chunk, signed?)
  #     |> update_stats(next_numbers)
  #     |> update_count_of_values(new_count)

  #   encode_chunks(tail, signed?, new_count, [new_row, previous_row | rows])
  # end

  # defp encode_chunks([chunk | tail], signed?, count, [row | rows]) do
  #   length = length(chunk)
  #   new_count = count + length

  #   new_row =
  #     row
  #     |> update_stats(chunk)
  #     |> update_binary(chunk, signed?)
  #     |> update_count_of_values(length)

  #   encode_chunks(tail, signed?, new_count, [new_row | rows])
  # end

  # defp update_stats(%Row{} = row, integers) do
  #   Map.update!(row, :stats, fn stats ->
  #     %{
  #       stats
  #       | minimum: safe_min(stats.minimum, integers),
  #         maximum: safe_max(stats.maximum, integers),
  #         sum: stats.sum + Enum.sum(integers)
  #     }
  #   end)
  # end

  # defp safe_min(nil, []), do: nil
  # defp safe_min(nil, list), do: Enum.min(list)
  # defp safe_min(cur, []), do: cur
  # defp safe_min(cur, list), do: min(cur, Enum.min(list))

  # defp safe_max(nil, []), do: nil
  # defp safe_max(nil, list), do: Enum.max(list)
  # defp safe_max(cur, []), do: cur
  # defp safe_max(cur, list), do: max(cur, Enum.max(list))

  # defp update_binary(%Row{} = row, integers, signed?) do
  #   {binary, []} = Direct.encode(integers, signed?)

  #   %{row | binary: row.binary <> binary}
  # end

  # defp update_count_of_values(%Row{} = row, count) do
  #   %{row | values: row.values + count}
  # end
end
