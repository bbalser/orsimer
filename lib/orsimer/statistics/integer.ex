defimpl Orsimer.Statistics, for: Orsimer.Type.Integer do
  def calculate(_t, list) do

    [head | tail] = Enum.reject(list, &is_nil/1)

    {min, max, sum} =
      Enum.reduce(tail, {head, head, head}, fn i, {min, max, sum} ->
        {min(min, i), max(max, i), sum + i}
      end)

    nils? = Enum.any?(list, &is_nil/1)

    Orc.Proto.ColumnStatistics.new(
      numberOfValues: length(list),
      hasNull: nils?,
      intStatistics:
        Orc.Proto.IntegerStatistics.new(
          minimum: min,
          maximum: max,
          sum: sum
        )
    )
    |> List.wrap()
  end
end
