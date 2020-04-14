defmodule Orsimer.Type.String do
  defstruct [:name]

  def new(attrs \\ []) do
    struct(__MODULE__, attrs)
  end

  defimpl Orsimer.Type do
    def to_list(_t, _column \\ 0) do
      [Orc.Proto.Type.new(kind: :STRING)]
    end

    def column_encoding(_t) do
      [Orc.Proto.ColumnEncoding.new(kind: :DIRECT_V2)]
    end

    def streams(_t, data, column \\ 0) do
      {length, data} = Orsimer.RLEv2.String.Direct.encode(data)
      compressed_length = Orsimer.Compression.compress(length)
      compressed_data = Orsimer.Compression.compress(data)

      streams = [
        Orc.Proto.Stream.new(column: column, kind: :LENGTH, length: byte_size(compressed_length)),
        Orc.Proto.Stream.new(column: column, kind: :DATA, length: byte_size(compressed_data))
      ]

      {streams, [compressed_length, compressed_data]}
    end
  end
end
