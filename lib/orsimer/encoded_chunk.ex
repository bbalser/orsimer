defmodule Orsimer.EncodedChunk do

  @type t :: %__MODULE__{
    binary: binary(),
    stats: Orc.Proto.ColumnStatistics.t()
  }

  @enforce_keys [:binary, :stats]
  defstruct [:binary, :stats]

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end

  def value_count(%__MODULE__{stats: stats}) do
    stats.numberOfValues
  end

  def binary_size(%__MODULE__{binary: binary}) do
    byte_size(binary)
  end

  def binary(%__MODULE__{binary: binary}), do: binary

  def stats(%__MODULE__{stats: stats}), do: stats

end
