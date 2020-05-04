defprotocol Orsimer.Decoder do
  @spec decode(t, [{Orsimer.stream_kind(), Orsimer.compressed_binary_stream()}], keyword()) :: list()
  def decode(t, streams, opts)

  @spec decode(t, [{Orsimer.stream_kind(), Orsimer.compressed_binary_stream()}]) :: list()
  def decode(t, streams)
end
