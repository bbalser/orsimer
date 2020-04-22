defmodule Orsimer.RLE.BooleanTest do
  use ExUnit.Case

  test "1 true followed by 7 false" do
    input = [true] ++ Enum.map(1..7, fn _ -> false end)

    encoded = Orsimer.RLE.Boolean.encode(input)

    assert Base.encode16(encoded, case: :lower) == "ff80"
  end
end
