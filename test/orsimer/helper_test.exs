defmodule Orsimer.HelperTest do
  use ExUnit.Case
  import Checkov

  data_test "returns minimum number of bits: #{bits} for #{inspect(input)}" do

    assert bits == Orsimer.Helper.minimum_bits(input)

    where [
      [:bits, :input],
      [2, [1, 2]],
      [4, [1, 7]],
      [16, [23713, 43806, 57005, 48879]]
    ]

  end
end
