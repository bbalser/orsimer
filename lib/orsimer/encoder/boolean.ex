defimpl Orsimer.Encoder, for: Orsimer.Type.Boolean do
  alias Orsimer.EncodedChunk
  alias Orsimer.CompressedBlock

  @chunk_size 1024

  def encode(type, list, opts \\ []) do
    column = Keyword.get(opts, :column, 0)

    chunks = encoded_chunks(type, list)
    blocks = compressed_blocks(type, chunks)

    Orsimer.Index.index_positions(blocks, fn c, d, l ->
      [c, d, div(l, 8), 0]
    end)

    Orsimer.Encoder.Result.new(
      column: column,
      data_streams: [DATA: Enum.map(blocks, &CompressedBlock.binary/1) |> Enum.join()]
    )
    |> List.wrap()
  end

  defp encoded_chunks(type, list) do
    list
    |> Enum.chunk_every(@chunk_size)
    |> Enum.map(&encoded_chunk(type, &1))
  end

  defp encoded_chunk(type, list) do
    EncodedChunk.new(
      binary: Orsimer.RLE.Boolean.encode(list),
      stats: stats(type, list)
    )
  end

  defp compressed_blocks(type, chunks) do
    chunks
    |> Enum.reduce([CompressedBlock.new()], fn chunk, [block | tail] ->
      case CompressedBlock.fit?(block, chunk) do
        true ->
          [CompressedBlock.add(block, chunk) | tail]

        false ->
          new_block = CompressedBlock.new() |> CompressedBlock.add(chunk)
          [new_block, block | tail]
      end
    end)
    |> Enum.reverse()
    |> Enum.map(&CompressedBlock.compress(&1, type))
  end

  defp stats(type, list) do
    [stats] = Orsimer.Statistics.calculate(type, list)
    stats
  end

  # use Orsimer.Encoder.Base

  # @values_per_byte 8

  # def chunk_size(), do: 1024

  # def create_chunk_encoder(_opts) do
  #   &Orsimer.RLE.Boolean.encode/1
  # end

  # def index_positions(binary, leftover) do
  #   [0, byte_size(binary), leftover_bytes(length(leftover)), 0]
  # end

  # defp leftover_bytes(length) do
  #   (length / @values_per_byte)
  #   |> Float.ceil()
  #   |> round()
  # end
end
