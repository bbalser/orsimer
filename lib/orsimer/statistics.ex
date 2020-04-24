defprotocol Orsimer.Statistics do
  @spec calculate(t, list) :: [Orc.Proto.ColumnStatistics.t()]
  def calculate(t, list)
end
