defmodule Orsimer.Type.Struct do
  defstruct [:name, :children]

  def new(attrs) do
    struct(__MODULE__, attrs)
  end

  defimpl Orsimer.Type do
    def to_list(%{children: children}, column \\ 0) do
      child_types =
        children
        |> Enum.with_index()
        |> Enum.map(fn {child, index} -> Orsimer.Type.to_list(child, column + index + 1) end)

      type =
        Orc.Proto.Type.new(
          kind: :STRUCT,
          fieldNames: Enum.map(children, &Map.get(&1, :name)),
          subtypes: (column + 1)..(column + length(children)) |> Enum.to_list()
        )

      [type | child_types]
      |> List.flatten()
    end

    def column_encoding(%{children: children}) do
      [
        Orc.Proto.ColumnEncoding.new(kind: :DIRECT)
        | Enum.map(children, &Orsimer.Type.column_encoding/1)
      ]
      |> List.flatten()
    end


    def streams(%{children: children}, data, column \\ 0) do
      children
      |> Enum.with_index(1)
      |> Enum.reduce([], fn {child, index}, acc ->
        field_data = Enum.map(data, &Map.get(&1, child.name))
        streams = Orsimer.Type.streams(child, field_data, column + index)

        [acc | streams]
      end)
      |> List.flatten()
    end
  end
end
