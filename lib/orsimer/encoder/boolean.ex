defimpl Orsimer.Encoder, for: Orsimer.Type.Boolean do
  use Orsimer.Encoder.Base

  @values_per_byte 8

  def chunk_size(), do: 1024

  def create_chunk_encoder(_opts) do
    &Orsimer.RLE.Boolean.encode/1
  end

  def index_positions(binary, leftover) do
    [0, byte_size(binary), leftover_bytes(length(leftover)), 0]
  end

  defp leftover_bytes(length) do
    (length / @values_per_byte)
    |> Float.ceil()
    |> round()
  end
end
