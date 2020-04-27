defimpl Orsimer.Encoder, for: Orsimer.Type.Boolean do
  @chunk_size 1024
  @row_size 10_000
  @values_per_byte 8

  def encode(t, list, opts \\ []) do
    column = Keyword.get(opts, :column, 0)

    result =
      list
      |> Enum.chunk_every(@row_size)
      |> encode_chunks(%{binary: <<>>, leftover: [], entries: []}, t)

    [
      %Orsimer.Encoder.Result{
        column: column,
        index: Orc.Proto.RowIndex.new(entry: Enum.reverse(result.entries)),
        data_streams: [DATA: result.binary]
      }
    ]
  end

  defp encode_chunks([chunk], acc, type) do
    binary =
      (acc.leftover ++ chunk)
      |> Enum.chunk_every(@chunk_size)
      |> Enum.map(&Orsimer.RLE.Boolean.encode/1)
      |> Enum.join()

    entry =
      Orc.Proto.RowIndexEntry.new(
        positions: [0, byte_size(acc.binary), leftover_bytes(length(acc.leftover)), 0],
        statistics: stats(type, chunk)
      )

    %{acc | leftover: [], binary: acc.binary <> binary, entries: [entry | acc.entries]}
  end

  defp encode_chunks([chunk | tail], acc, type) do
    need_to_encode = acc.leftover ++ chunk
    can_encode_count = div(length(need_to_encode), @chunk_size) * @chunk_size

    binary =
      need_to_encode
      |> Enum.take(can_encode_count)
      |> Enum.chunk_every(@chunk_size)
      |> Enum.map(&Orsimer.RLE.Boolean.encode/1)
      |> Enum.join()

    entry =
      Orc.Proto.RowIndexEntry.new(
        positions: [0, byte_size(acc.binary), leftover_bytes(length(acc.leftover)), 0],
        statistics: stats(type, chunk)
      )

    new_acc = %{
      acc
      | leftover: Enum.drop(need_to_encode, can_encode_count),
        binary: acc.binary <> binary,
        entries: [entry | acc.entries]
    }

    encode_chunks(tail, new_acc, type)
  end

  defp stats(type, list) do
    [stats] = Orsimer.Statistics.calculate(type, list)
    stats
  end

  defp leftover_bytes(length) do
    (length / @values_per_byte)
    |> Float.ceil()
    |> round()
  end
end
