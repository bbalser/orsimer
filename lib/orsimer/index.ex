defmodule Orsimer.Index do
  alias Orsimer.CompressedBlock
  alias Orsimer.EncodedChunk

  @row_size 10_000

  @spec create_row_index(
          Orsimer.Statistics.t(),
          [CompressedBlock.t()],
          (compressed :: non_neg_integer(),
           decompressed :: non_neg_integer(),
           leftover :: non_neg_integer() ->
             list())
        ) :: Orc.Proto.RowIndex.t()
  def create_row_index(type, blocks, position \\ &create_position/3) do
    indexes = index_blocks(blocks)

    entries =
      determine_positions(indexes, position)
      |> Enum.map(fn positions -> Orc.Proto.RowIndexEntry.new(positions: positions) end)

    Orc.Proto.RowIndex.new(entry: entries)
  end

  defp index_blocks(blocks) do
    {indexes, _} =
      blocks
      |> Enum.flat_map_reduce(%{prev_block: 0, prev_chunk: 0}, fn block, acc ->
        chunk_indexes = index_chunks(CompressedBlock.encoded_chunks(block), acc)

        {chunk_indexes,
         Map.update!(acc, :prev_block, fn pb -> pb + CompressedBlock.binary_size(block) end)}
      end)

    indexes
  end

  defp index_chunks(chunks, accumulator) do
    {indexes, _} =
      chunks
      |> Enum.map_reduce(accumulator, fn chunk, acc ->
        {%{
           block: acc.prev_block,
           chunk: acc.prev_chunk,
           count: EncodedChunk.value_count(chunk)
         }, Map.update!(acc, :prev_chunk, fn pc -> pc + EncodedChunk.binary_size(chunk) end)}
      end)

    indexes
  end

  defp determine_positions(indexes, position) do
    [position.(0, 0, 0)] ++
      Enum.chunk_while(
        indexes,
        %{start_block: 0, start_chunk: 0, count: 0},
        fn index, acc ->
          case index.count + acc.count > @row_size do
            false ->
              {:cont, %{acc | count: acc.count + index.count}}

            true ->
              leftover = @row_size - acc.count
              chunk = position.(index.block, index.chunk, leftover)
              {:cont, chunk, %{acc | count: index.count - leftover}}
          end
        end,
        fn acc -> {:cont, acc} end
      )
  end

  defp create_position(compressed, decompressed, leftover) do
    [compressed, decompressed, leftover]
  end
end
