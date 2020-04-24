defimpl Orsimer.Decoder, for: Orsimer.Type.Integer do
  alias Orsimer.RLEv2.Integer.{Delta, Direct}

  def decode(_t, [{:DATA, data_stream}], opts \\ []) do
    signed? = Keyword.get(opts, :signed?, false)
    do_decode(data_stream, signed?, [])
  end

  defp do_decode(<<>>, _signed?, buffer), do: List.flatten(buffer)

  defp do_decode(<<1::size(2), _::bitstring>> = binary, signed?, buffer) do
    {integers, remaining} = Direct.decode(binary, signed?)
    do_decode(remaining, signed?, [buffer | integers])
  end

  defp do_decode(<<3::size(2), _::bitstring>> = binary, signed?, buffer) do
    {integers, remaining} = Delta.decode(binary, signed?)
    do_decode(remaining, signed?, [buffer | integers])
  end
end
