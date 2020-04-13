defmodule Orsimer.Helper do

  @bits [0, 1, 2, 4, 8, 16, 24, 32, 40, 48, 56, 64]

  def minimum_bits(integers) do
    max_bits =
    integers
    |> Enum.map(&Integer.digits(&1, 2))
    |> Enum.map(&length/1)
    |> Enum.max()

    Enum.find(@bits, fn bits -> bits >= max_bits end)
  end

end
