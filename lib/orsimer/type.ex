defprotocol Orsimer.Type do
  @spec to_list(t) :: [Orc.Proto.Type.t()]
  def to_list(t)

  @spec to_list(t, non_neg_integer()) :: [Orc.Proto.Type.t()]
  def to_list(t, column)

  @spec column_encoding(t) :: [Orc.Proto.ColumnEncoding.t()]
  def column_encoding(t)

  @spec streams(t, list()) :: {[Orc.Proto.Stream.t()], [binary], [Orc.Proto.RowIndex.t()]}
  def streams(t, data)

  @spec streams(t, list(), non_neg_integer()) ::
          {[Orc.Proto.Stream.t()], [binary], [Orc.Proto.RowIndex.t()]}
  def streams(t, data, column)
end
