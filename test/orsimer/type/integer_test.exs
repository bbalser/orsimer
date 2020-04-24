defmodule Orsimer.Type.IntegerTest do
  use ExUnit.Case

  setup do
    type = Orsimer.Type.Integer.new(name: "something")

    [type: type]
  end

  describe "to_list" do
    test "creates Orc.Proto.Type", %{type: type} do
      assert [Orc.Proto.Type.new(kind: :LONG)] == Orsimer.Type.to_list(type)
    end
  end

  describe "column_encoding" do
    test "creates column encoding", %{type: type} do
      assert [Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)] ==
               Orsimer.Type.column_encoding(type)
    end
  end

  describe "streams" do
    test "creates data stream", %{type: type} do
      data = random_numbers(1_000)

      {_, [binary]} = Orsimer.Type.streams(type, data)

      actual =
        binary
        |> Orsimer.Compression.decompress()
        |> Orsimer.RLEv2.Integer.Direct.decode(true)

      assert data == actual
    end

    test "create Orc.Proto.Stream", %{type: type} do
      data = random_numbers(1_000)

      {[stream], [binary]} = Orsimer.Type.streams(type, data)

      assert Orc.Proto.Stream.new(column: 0, kind: :DATA, length: byte_size(binary)) == stream
    end
  end

  describe "indexes" do
    test "creates binary", %{type: type} do
      data = random_numbers(1_000)

      {[_stream], [binary]} = Orsimer.Type.indexes(type, data)

      entry =
        binary
        |> Orsimer.Compression.decompress()
        |> Orc.Proto.RowIndex.decode()
        |> Map.get(:entry)
        |> List.first()

      assert entry.statistics.numberOfValues == 1_000
      assert entry.statistics.hasNull == false

      assert entry.statistics.intStatistics ==
               Orc.Proto.IntegerStatistics.new(
                 minimum: Enum.min(data),
                 maximum: Enum.max(data),
                 sum: Enum.sum(data)
               )

      assert entry.positions == [0, 0, 0]
    end

    test "creates stream", %{type: type} do
      data = random_numbers(1_000)

      {[stream], [binary]} = Orsimer.Type.indexes(type, data)

      assert stream == Orc.Proto.Stream.new(column: 0, kind: :ROW_INDEX, length: byte_size(binary))
    end
  end

  defp random_numbers(n) do
    Enum.map(1..n, fn _ -> :rand.uniform(1_000_000) end)
  end
end
