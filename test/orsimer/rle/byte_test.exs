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

  test "literal decoding" do
    bytes = Base.decode16!("fe4445", case: :lower)

    {decoded, <<67, 89>>} = Orsimer.RLE.Byte.decode(bytes <> <<67, 89>>)

    assert decoded == binary_part(bytes, 1, 2)
  end

  test "run length decoding" do
    bytes = Base.decode16!("6100", case: :lower)

    {decoded, <<89, 67>>} = Orsimer.RLE.Byte.decode(bytes <> <<89, 67>>)

    assert Enum.reduce(1..100, <<>>, fn _, acc -> acc <> <<0>> end) == decoded
  end
end
