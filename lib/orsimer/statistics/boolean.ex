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

  def merge(_t, stats1, stats2) do
    %{
      stats1
      | numberOfValues: stats1.numberOfValues + stats2.numberOfValues,
        bucketStatistics: merge_stats(stats1.bucketStatistics, stats2.bucketStatistics)
    }
  end

  defp merge_stats(%{count: [count1]} = bucket1, %{count: [count2]}) do
    %{bucket1 | count: [count1 + count2]}
  end
end
