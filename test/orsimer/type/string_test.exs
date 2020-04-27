defmodule Orsimer.Type.StringTest do
  use ExUnit.Case

  setup do
    type = Orsimer.Type.String.new(name: "something")

    [type: type]
  end

  describe "to_list" do
    test "creates Orc.Proto.Type", %{type: type} do
      assert [Orc.Proto.Type.new(kind: :STRING)] == Orsimer.Type.to_list(type)
    end
  end

  describe "column_encoding" do
    test "create Orc.Proto.ColumnEncoding", %{type: type} do
      assert [Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)] == Orsimer.Type.column_encoding(type)
    end
  end

  describe "streams" do
    test "will create binary streams", %{type: type} do
      data = Enum.map(1..1_000, fn _ -> random_string(:rand.uniform(10)) end)

      {_, [ls, ds], _} = Orsimer.Type.streams(type, data)
      length_stream = Orsimer.Compression.decompress(ls)
      data_stream = Orsimer.Compression.decompress(ds)

      assert data == Orsimer.RLEv2.String.Direct.decode(length_stream, data_stream)
    end

    test "will create Orc.Proto.Stream list", %{type: type} do
      data = Enum.map(1..1_000, fn _ -> random_string(:rand.uniform(10)) end)

      {streams, [ls, ds], _} = Orsimer.Type.streams(type, data)
      assert Enum.at(streams, 0) == Orc.Proto.Stream.new(column: 0, kind: :LENGTH, length: byte_size(ls))
      assert Enum.at(streams, 1) == Orc.Proto.Stream.new(column: 0, kind: :DATA, length: byte_size(ds))
    end

    test "will create row index", %{type: type} do

    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
