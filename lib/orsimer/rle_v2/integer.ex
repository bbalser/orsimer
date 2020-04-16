defmodule Orsimer.RLEv2.Integer do
  alias Orsimer.RLEv2.Integer.{Delta, Direct}

  def encode(integers, signed? \\ false, buffer \\ <<>>)

  def encode([], _signed?, buffer), do: buffer

  def encode(integers, signed?, buffer) do
    {binary, remaining} = Direct.encode(integers, signed?)
    encode(remaining, signed?, buffer <> binary)
  end

  def decode(binary, signed? \\ false, buffer \\ [])

  def decode(<<>>, _signed?, buffer), do: List.flatten(buffer)

  def decode(<<1::size(2), _::bitstring>> = binary, signed?, buffer) do
    {integers, remaining} = Direct.decode(binary, signed?)
    decode(remaining, signed?, [buffer | integers])
  end

  def decode(<<3::size(2), _::bitstring>> = binary, signed?, buffer) do
    {integers, remaining} = Delta.decode(binary, signed?)
    decode(remaining, signed?, [buffer | integers])
  end
end
