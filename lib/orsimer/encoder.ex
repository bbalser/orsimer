defmodule Orsimer.Encoder.Result do

  @type t :: %__MODULE__{
    column: non_neg_integer(),
    index: Orc.Proto.RowIndex.t(),
    data_streams: [{Orsimer.stream_kind(), Orsimer.compressed_binary_stream()}]
  }

  defstruct column: nil,
    index: nil,
    data_streams: []

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end
end

defprotocol Orsimer.Encoder do
  @spec encode(t, list(), keyword()) :: [Orsimer.Encoder.Result.t()]
  def encode(t, list, opts)
  @spec encode(t, list()) :: [Orsimer.Encoder.Result.t()]
  def encode(t, list)
end

