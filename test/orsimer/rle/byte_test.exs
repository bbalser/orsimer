defmodule Orsimer.RLE.ByteTest do
  use ExUnit.Case

  test "literal encoding" do
    bytes = Base.decode16!("4445", case: :lower)

    encoded = Orsimer.RLE.Byte.encode(bytes)

    <<header::integer-signed-size(8), rest::binary>> = encoded

    assert header ==  - byte_size(bytes)
    assert rest == bytes
    assert Base.encode16(encoded, case: :lower) == "fe4445"
  end
end
