defmodule Orsimer.RLEv2.IntegerTest do
  use ExUnit.Case

  describe "encode" do
    test "will encode a list of integers in direct encoding" do
      integers = random_numbers(4367)

      binary_stream = Orsimer.RLEv2.Integer.encode(integers, true)
      decoded = Orsimer.RLEv2.Integer.decode(binary_stream, true)

      assert decoded == integers
    end
  end


  defp random_numbers(n) do
    Enum.map(1..n, fn _ -> :rand.uniform(1_000_000) end)
  end
end
