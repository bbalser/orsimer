defmodule Orsimer.RLE.BooleanTest do
  use ExUnit.Case

  test "1 true followed by 7 false" do
    input = [true] ++ Enum.map(1..7, fn _ -> false end)

    encoded = Orsimer.RLE.Boolean.encode(input)

    assert Base.encode16(encoded, case: :lower) == "ff80"
  end

  test "decodeing ff80 into 1 true followed by 7 false" do
    bytes = Base.decode16!("ff80", case: :lower)

    {decoded, <<67, 89>>} = Orsimer.RLE.Boolean.decode(bytes <> <<67, 89>>)

    assert decoded == [true] ++ Enum.map(1..7, fn _ -> false end)
  end
end
