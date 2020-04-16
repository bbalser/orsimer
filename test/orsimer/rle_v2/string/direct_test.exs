defmodule Orsimer.RLEv2.String.DirectTest do
  use ExUnit.Case

  describe "encode" do
    test "encodes strings into 2 streams" do
      strings = ["one", "two", "three", "four", "five"]

      {length, data} = Orsimer.RLEv2.String.Direct.encode(strings)

      assert [3, 3, 5, 4, 4] = Orsimer.RLEv2.Integer.decode(length)
      assert "onetwothreefourfive" = data
    end
  end

  describe "decode" do
    test "decodes binary into strings" do
      strings = ["one", "two", "three", "four", "five"]
      {length, data} = Orsimer.RLEv2.String.Direct.encode(strings)

      output = Orsimer.RLEv2.String.Direct.decode(length, data)

      assert strings == output
    end
  end


end
