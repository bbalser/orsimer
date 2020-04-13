defmodule Orsimer.RLEv2.FiveBit do

  @width_to_encoded %{
    0 => 0,
    1 => 0,
    2 => 1,
    4 => 3,
    8 => 7,
    16 => 15,
    24 => 23,
    32 => 27,
    40 => 28,
    48 => 29,
    56 => 30,
    64 => 31
  }

  @encoded_to_width Enum.map(@width_to_encoded, fn {a, b} -> {b, a} end) |> Map.new()

  def encode(width) do
    Map.get(@width_to_encoded, width)
  end

  def decode(encoded) do
    Map.get(@encoded_to_width, encoded)
  end
end
