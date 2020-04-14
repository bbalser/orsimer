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

    test "creates Orc.Proto.Type with column number", %{type: type} do
      assert [Orc.Proto.Type.new(kind: :LONG, column: 12)] == Orsimer.Type.to_list(type, 12)
    end
  end

  describe "column_encoding" do
    test "creates column encoding", %{type: type} do
      assert [Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)] == Orsimer.Type.column_encoding(type)
    end
  end

  describe "streams" do
    test "creates data stream", %{type: type} do
      data = random_numbers(1_000)

      {_, [binary], _} = Orsimer.Type.streams(type, data)

      actual =
        binary
        |> Orsimer.Compression.decompress()
        |> Orsimer.RLEv2.Integer.Direct.decode(true)

      assert data == actual
    end

    test "create Orc.Proto.Stream", %{type: type} do
      data = random_numbers(1_000)

      {[stream], [binary], _} = Orsimer.Type.streams(type, data)

      assert Orc.Proto.Stream.new(column: 0, kind: :DATA, length: byte_size(binary)) == stream
    end

    test "creates RowIndex", %{type: type} do
      data = random_numbers(1_000)

      {_, _, [%Orc.Proto.RowIndex{entry: [index]}]} = Orsimer.Type.streams(type, data)

      assert index.statistics.numberOfValues == 1_000
      assert index.statistics.hasNull == false
      assert index.statistics.intStatistics == Orc.Proto.IntegerStatistics.new(
        minimum: Enum.min(data),
        maximum: Enum.max(data),
        sum: Enum.sum(data)
      )
      assert index.positions == [0, 0, 0]
    end
  end

  defp random_numbers(n) do
    Enum.map(1..n, fn _ -> :rand.uniform(1_000_000) end)
  end

end
