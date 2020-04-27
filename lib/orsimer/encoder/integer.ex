defimpl Orsimer.Encoder, for: Orsimer.Type.Integer do
  use Orsimer.Encoder.Base

  alias Orsimer.RLEv2.Integer.Direct

  def chunk_size(), do: 512

  def create_chunk_encoder(opts) do
    signed? = Keyword.get(opts, :signed?, false)

    fn chunk ->
      Direct.encode(chunk, signed?)
    end
  end

  def index_positions(binary, leftover) do
    [0, byte_size(binary), length(leftover)]
  end

end
