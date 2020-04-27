defimpl Orsimer.Encoder, for: Orsimer.Type.Struct do
  def encode(%{children: children}, data, opts \\ []) do
    column = Keyword.get(opts, :column, 0)

    children
    |> Enum.with_index(1)
    |> Enum.reduce([], fn {child, index}, acc ->
      field_data = Enum.map(data, &Map.get(&1, child.name))
      results = Orsimer.Encoder.encode(child, field_data, column: column + index)

      [acc | results]
    end)
    |> List.flatten()
  end
end
