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
  end
end
