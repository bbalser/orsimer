defmodule Orsimer.TypeTest do
  use ExUnit.Case

  setup do
    type =
      Orsimer.Type.Struct.new(
        children: [
          Orsimer.Type.Integer.new(name: "id"),
          Orsimer.Type.String.new(name: "name"),
          Orsimer.Type.Struct.new(
            name: "spouse",
            children: [
              Orsimer.Type.String.new(name: "name")
            ]
          )
        ]
      )

    [type: type]
  end

  describe "to_list" do
    test "orders type in list", %{type: type} do
      output = Orsimer.Type.to_list(type)

      assert Enum.at(output, 0) ==
               Orc.Proto.Type.new(
                 kind: :STRUCT,
                 fieldNames: ["id", "name", "spouse"],
                 subtypes: [1, 2, 3]
               )

      assert Enum.at(output, 1) == Orc.Proto.Type.new(kind: :LONG)
      assert Enum.at(output, 2) == Orc.Proto.Type.new(kind: :STRING)

      assert Enum.at(output, 3) ==
               Orc.Proto.Type.new(kind: :STRUCT, fieldNames: ["name"], subtypes: [4])

      assert Enum.at(output, 4) == Orc.Proto.Type.new(kind: :STRING)
    end
  end

  describe "column_encoding" do
    test "orders encodings into list", %{type: type} do
      output = Orsimer.Type.column_encoding(type)

      assert Enum.at(output, 0) == Orc.Proto.ColumnEncoding.new(kind: :DIRECT)
      assert Enum.at(output, 1) == Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)
      assert Enum.at(output, 2) == Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)
      assert Enum.at(output, 3) == Orc.Proto.ColumnEncoding.new(kind: :DIRECT)
      assert Enum.at(output, 2) == Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)
    end
  end
end
