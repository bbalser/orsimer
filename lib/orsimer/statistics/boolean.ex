defimpl Orsimer.Statistics, for: Orsimer.Type.Boolean do
  def calculate(_t, list) do
    [
      Orc.Proto.ColumnStatistics.new(
        numberOfValues: length(list),
        bucketStatistics:
          Orc.Proto.BucketStatistics.new(count: [Enum.filter(list, & &1) |> length()])
      )
    ]
  end
end
