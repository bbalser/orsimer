defprotocol Orsimer.Statistics do
  @spec calculate(t, list) :: [Orc.Proto.ColumnStatistics.t()]
  def calculate(t, list)

  @spec merge(t, Orc.Proto.ColumnStatistics.t(), Orc.Proto.ColumnStatistics.t()) :: Orc.Proto.ColumnStatistics.t()
  def merge(t, stats1, stats2)
end
