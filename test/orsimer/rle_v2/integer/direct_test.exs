defmodule Orsimer.RLEv2.Integer.DirectTest do
  use ExUnit.Case

  describe "encode" do
    test "encodes unsigned integers in direct encoding" do
      integers = [23713, 43806, 57005, 48879]
      output = Orsimer.RLEv2.Integer.Direct.encode(integers)

      <<encoding::size(2),
        width::size(5),
        length::size(9),
        first::size(16),
        second::size(16),
        third::size(16),
        fourth::size(16)>> = output

      assert encoding == 1
      assert width == 15
      assert length == 3
      assert first == 23713
      assert second == 43806
      assert third == 57005
      assert fourth == 48879

      assert Base.encode16(output, case: :lower) == "5e035ca1ab1edeadbeef"
    end

    test "encodes signed integers with zigzab algorithm" do
      integers = [-23713, 43806, -57005, 48879]
      output = Orsimer.RLEv2.Integer.Direct.encode(integers, true)

      <<encoding::size(2),
        width::size(5),
        length::size(9),
        first::size(24),
        second::size(24),
        third::size(24),
        fourth::size(24)>> = output

      assert encoding == 1
      assert width == 23
      assert length == 3
      assert first == Varint.Zigzag.encode(-23713)
      assert second == Varint.Zigzag.encode(43806)
      assert third == Varint.Zigzag.encode(-57005)
      assert fourth == Varint.Zigzag.encode(48879)
    end
  end

  describe "decode" do
    test "decodes unsigned integers" do
      integers = [23713, 43806, 57005, 48879]
      encoded = Orsimer.RLEv2.Integer.Direct.encode(integers)

      decoded = Orsimer.RLEv2.Integer.Direct.decode(encoded)

      assert integers == decoded
    end

    test "decodes signed integers" do
      integers = [23713, -43806, 57005, 48879]
      encoded = Orsimer.RLEv2.Integer.Direct.encode(integers, true)

      decoded = Orsimer.RLEv2.Integer.Direct.decode(encoded, true)

      assert integers == decoded
    end
  end

end
