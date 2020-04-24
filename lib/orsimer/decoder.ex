defprotocol Orsimer.Decoder do
  @spec decode(t, Orsimer.streams(), keyword()) :: list()
  def decode(t, streams, opts)

  @spec decode(t, Orsimer.streams()) :: list()
  def decode(t, streams)
end
