defmodule Orsimer.CompressedBlock do
  alias Orsimer.EncodedChunk

  @max_size 262_144

  @type t :: %__MODULE__{
          estimated_size: pos_integer(),
          encoded_chunks: [Orsimer.EncodedChunk.t()],
          binary: binary,
          stats: Orc.Proto.ColumnStatistics.t()
        }

  defstruct estimated_size: 0, encoded_chunks: [], binary: nil, stats: nil

  def new() do
    %__MODULE__{}
  end

  def binary(%__MODULE__{binary: binary}), do: binary

  def binary_size(block) do
    block
    |> binary()
    |> byte_size()
  end

  def encoded_chunks(%__MODULE__{encoded_chunks: encoded_chunks}), do: encoded_chunks

  def fit?(%__MODULE__{} = block, %EncodedChunk{} = chunk) do
    EncodedChunk.binary_size(chunk) + block.estimated_size <= @max_size
  end

  def add(%__MODULE__{} = block, %EncodedChunk{} = chunk) do
    %{
      block
      | encoded_chunks: block.encoded_chunks ++ [chunk],
        estimated_size: block.estimated_size + EncodedChunk.binary_size(chunk)
    }
  end

  def compress(%__MODULE__{} = block, type) do
    compressed_binary =
      block.encoded_chunks
      |> Enum.map(&EncodedChunk.binary/1)
      |> Enum.join()
      |> Orsimer.Compression.compress()

    stats =
      block.encoded_chunks
      |> Enum.map(&EncodedChunk.stats/1)
      |> Enum.reduce(fn stat, acc ->
        Orsimer.Statistics.merge(type, acc, stat)
      end)

    %{block | binary: compressed_binary, stats: stats}
  end
end
