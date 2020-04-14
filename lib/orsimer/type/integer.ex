defmodule Orsimer.Type.Integer do
  defstruct [:name]

  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  defimpl Orsimer.Type do
    def to_list(_t, _column \\ 0) do
      [Orc.Proto.Type.new(kind: :LONG)]
    end

    def column_encoding(_t) do
      [Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)]
    end

    def streams(_t, data, column \\ 0) do
      binary =
        Orsimer.RLEv2.Integer.Direct.encode(data, true)
        |> Orsimer.Compression.compress()

      stream = Orc.Proto.Stream.new(column: column, kind: :DATA, length: byte_size(binary))

      {[stream], [binary], [row_index(data)]}
    end

    defp row_index(data) do
      Orc.Proto.RowIndex.new(
        entry: [
          Orc.Proto.RowIndexEntry.new(
            positions: [0, 0, 0],
            statistics:
              Orc.Proto.ColumnStatistics.new(
                numberOfValues: length(data),
                hasNull: false,
                intStatistics:
                  Orc.Proto.IntegerStatistics.new(
                    minimum: Enum.min(data),
                    maximum: Enum.max(data),
                    sum: Enum.sum(data)
                  )
              )
          )
        ]
      )
    end
  end
end
