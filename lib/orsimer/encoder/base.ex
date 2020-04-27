defmodule Orsimer.Encoder.Base do
  @callback row_size() :: pos_integer()
  @callback chunk_size() :: pos_integer()
  @callback create_chunk_encoder(keyword()) :: (list() -> binary())
  @callback index_positions(binary, leftover :: list) :: [non_neg_integer()]

  defmacro __using__(_opts) do
    quote do
      @behaviour Orsimer.Encoder.Base

      def row_size, do: 10_000

      def encode(type, list, opts \\ []) do
        column = Keyword.get(opts, :column, 0)
        chunk_encoder = create_chunk_encoder(opts)

        case Orsimer.Encoder.Base.has_nulls?(list) do
          true ->
            non_nil_values = Enum.reject(list, &is_nil/1)
            result = __encode_values__(type, non_nil_values, chunk_encoder)

            booleans = Enum.map(list, &(not is_nil(&1)))

            [%{index: presence_index, data_streams: [{:DATA, presence_stream}]}] =
              Orsimer.Encoder.encode(Orsimer.Type.Boolean.new(), booleans)

            entries =
              result.entries
              |> Enum.reverse()
              |> Enum.zip(presence_index.entry)
              |> Enum.map(fn {value_index, bool_index} ->
                %{value_index | positions: bool_index.positions ++ value_index.positions}
              end)

            %Orsimer.Encoder.Result{
              column: column,
              index: Orc.Proto.RowIndex.new(entry: entries),
              data_streams: [PRESENT: presence_stream, DATA: result.binary]
            }

          false ->
            result = __encode_values__(type, list, chunk_encoder)

            %Orsimer.Encoder.Result{
              column: column,
              index: Orc.Proto.RowIndex.new(entry: Enum.reverse(result.entries)),
              data_streams: [DATA: result.binary]
            }
        end
        |> List.wrap()
      end

      defp __encode_values__(type, values, chunk_encoder) do
        values
        |> Enum.chunk_every(row_size())
        |> __encode_chunks__(%{binary: <<>>, leftover: [], entries: []}, type, chunk_encoder)
      end

      defp __encode_chunks__([chunk], acc, type, chunk_encoder) do
        binary =
          (acc.leftover ++ chunk)
          |> Enum.chunk_every(chunk_size())
          |> Enum.map(chunk_encoder)
          |> Enum.join()

        entry =
          Orc.Proto.RowIndexEntry.new(
            positions: index_positions(acc.binary, acc.leftover),
            statistics: Orsimer.Encoder.Base.stats(type, chunk)
          )

        %{acc | leftover: [], binary: acc.binary <> binary, entries: [entry | acc.entries]}
      end

      defp __encode_chunks__([chunk | tail], acc, type, chunk_encoder) do
        need_to_encode = acc.leftover ++ chunk
        can_encode_count = div(length(need_to_encode), chunk_size()) * chunk_size()

        binary =
          need_to_encode
          |> Enum.take(can_encode_count)
          |> Enum.chunk_every(chunk_size())
          |> Enum.map(chunk_encoder)
          |> Enum.join()

        entry =
          Orc.Proto.RowIndexEntry.new(
            positions: index_positions(acc.binary, acc.leftover),
            statistics: Orsimer.Encoder.Base.stats(type, chunk)
          )

        new_acc = %{
          acc
          | leftover: Enum.drop(need_to_encode, can_encode_count),
            binary: acc.binary <> binary,
            entries: [entry | acc.entries]
        }

        __encode_chunks__(tail, new_acc, type, chunk_encoder)
      end

      defoverridable Orsimer.Encoder.Base
    end
  end

  def has_nulls?(list) do
    Enum.any?(list, &is_nil/1)
  end

  def stats(type, list) do
    [stats] = Orsimer.Statistics.calculate(type, list)
    stats
  end
end
