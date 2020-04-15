defmodule Orsimer.RLEv2.Integer.DeltaTest do
  use ExUnit.Case

  describe "encode" do
    test "encodes some data" do
      integers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

      bytes = Orsimer.RLEv2.Integer.Delta.encode(integers, false)

      <<encoding::size(2), width::size(5), length::size(9), rest::binary>> = bytes

      assert encoding == 3
      assert Orsimer.RLEv2.FiveBit.decode(width) == 4
      assert length + 1 == 10

      {base, rest} = Varint.LEB128.decode(rest)
      assert base == 2

      {first_delta, _} = Varint.LEB128.decode(rest)
      assert first_delta == 2

      assert Base.encode16(bytes, case: :lower)  == "c609020222424246"
    end

    test "encodes data as signed integers" do
      integers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

      bytes = Orsimer.RLEv2.Integer.Delta.encode(integers, true)

      <<_::binary-size(2), rest::binary>> = bytes

      {base, rest} = Varint.LEB128.decode(rest)
      assert Varint.Zigzag.decode(base) == 2

      {first_delta, _} = Varint.LEB128.decode(rest)
      assert first_delta == 2
    end
  end

  describe "decode" do
    test "decodes data stream into integers" do
      integers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

      bytes = Orsimer.RLEv2.Integer.Delta.encode(integers)

      assert integers == Orsimer.RLEv2.Integer.Delta.decode(bytes)
    end

    test "decodes data stream into signed integers" do
      integers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]

      bytes = Orsimer.RLEv2.Integer.Delta.encode(integers, true)

      assert integers == Orsimer.RLEv2.Integer.Delta.decode(bytes, true)
    end

    test "decodes data stream of signed integers going in negative direction" do
      integers = [-2, -3, -5, -7, -11, -13, -17, -19, -23, -29]

      bytes = Orsimer.RLEv2.Integer.Delta.encode(integers, true)

      assert integers == Orsimer.RLEv2.Integer.Delta.decode(bytes, true)
    end
  end

end
