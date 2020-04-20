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
      {row_index, streams} = Orsimer.RLEv2.Integer.encode(data, signed?: true)

      index_binary = row_index |> Orc.Proto.RowIndex.encode() |> Orsimer.Compression.compress()

      index_stream = {
        Orc.Proto.Stream.new(column: column, kind: :ROW_INDEX, length: byte_size(index_binary)),
        index_binary
      }

      data_streams =
        Enum.map(streams, fn {kind, binary} ->
          compressed_binary = Orsimer.Compression.compress(binary)

          stream =
            Orc.Proto.Stream.new(column: column, kind: kind, length: byte_size(compressed_binary))

          {stream, compressed_binary}
        end)

      [index_stream | data_streams]
    end
  end
end
