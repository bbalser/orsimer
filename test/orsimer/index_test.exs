defmodule Orsimer.IndexTest do
  use ExUnit.Case
  import TestData

  alias Orsimer.{CompressedBlock, EncodedChunk}

  defmodule TestType do
    defstruct []

    defimpl Orsimer.Statistics do
      def calculate(_, list) do
        Orc.Proto.ColumnStatistics.new(numberOfValues: length(list))
      end

      def merge(_, a, b) do
        Map.update!(a, :numberOfValues, &(&1 + b.numberOfValues))
      end
    end
  end

  setup do
    [type: %TestType{}]
  end

  test "will create default position when number of values less than 10_000", %{type: type} do
    block = block(chunks: [chunk(count: 9_999)])

    row_index = Orsimer.Index.create_row_index(type, [block])

    positions = Enum.map(row_index.entry, &Map.get(&1, :positions))

    assert positions = [[0, 0, 0]]
  end

  test "will use custom position function to create position array" do
    block = block(chunks: [chunk(count: 9_999)])

    positions = Orsimer.Index.positions([block], fn a, b, c -> [a, b, c, 0] end)

    assert positions = [[0, 0, 0, 0]]
  end

  test "creates positions for 2 chunk over 10_000 values" do
    chunk1 = chunk(count: 9_999)
    chunk2 = chunk(count: 10)

    block = block(chunks: [chunk1, chunk2])

    positions = Orsimer.Index.positions([block])

    assert positions = [
             [0, 0, 0],
             [0, EncodedChunk.binary_size(chunk1), 1]
           ]
  end

  test "multiple compressed blocks" do
    chunk1 = chunk(count: 9_999)
    chunk2 = chunk(count: 10)
    chunk3 = chunk(count: 12_000)
    chunk4 = chunk(count: 1_000)

    block1 = block(chunks: [chunk1, chunk2])
    block2 = block(chunks: [chunk3, chunk4])

    positions = Orsimer.Index.positions([block1, block2])

    assert positions == [
      [0, 0, 0],
      [0, EncodedChunk.binary_size(chunk1), 1],
      [CompressedBlock.binary_size(block1), 0,  9_991],
    ]
  end

  defp chunk(opts) do
    count = Keyword.fetch!(opts, :count)

    EncodedChunk.new(
      binary: random_string(1_000),
      stats: Orc.Proto.ColumnStatistics.new(numberOfValues: count)
    )
  end

  defp block(opts) do
    chunks = Keyword.fetch!(opts, :chunks)

    Enum.reduce(chunks, CompressedBlock.new(), &CompressedBlock.add(&2, &1))
    |> CompressedBlock.compress(%TestType{})
  end
end
