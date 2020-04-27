defimpl Orsimer.Statistics, for: Orsimer.Type.Struct do
  def calculate(%{children: children}, data) do
    stats =
      children
      |> Enum.map(fn child ->
      field_data = Enum.map(data, &Map.get(&1, child.name))
      Orsimer.Statistics.calculate(child, field_data)
    end)
    |> List.flatten()

      struct_stats = Orc.Proto.ColumnStatistics.new(numberOfValues: length(data))

      [struct_stats | stats]
  end
end
