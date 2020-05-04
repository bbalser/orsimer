defimpl Orsimer.Decoder, for: Orsimer.Type.Boolean do
  def decode(_t, [{:DATA, stream}], _opts \\ []) do
    stream
    |> Orsimer.Compression.decompress()
    |> Stream.unfold(fn
     <<>> -> nil
      binary -> Orsimer.RLE.Boolean.decode(binary)
    end)
    |> Enum.to_list()
    |> List.flatten()
  end
end
