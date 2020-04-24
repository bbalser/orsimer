defmodule Orsimer.Encoder.BooleanTest do
  use ExUnit.Case

  setup do
    [type: Orsimer.Type.Boolean.new()]
  end

  test "encodes booleans into data stream", %{type: type} do
    booleans = random_booleans(14_000)

    [result] = Orsimer.Encoder.encode(type, booleans)

    [{:DATA, binary_stream}] = result.data_streams

    actual =
      Stream.unfold(binary_stream, fn
        <<>> -> nil
        binary -> Orsimer.RLE.Boolean.decode(binary)
      end)
      |> Enum.to_list()
      |> List.flatten()

    assert 0 == result.column
    assert Enum.take(actual, length(booleans)) == booleans
  end

  test "encodes row index for every 10_000 booleans", %{type: type} do
    booleans = random_booleans(14_001)

    [result] = Orsimer.Encoder.encode(type, booleans)

    actual = Orsimer.Decoder.decode(type, result.data_streams)
    assert booleans == Enum.take(actual, length(booleans))

    [row1, row2] = result.index.entry

    assert [0, 0, 0, 0] = row1.positions
    assert [0, 1161, 98, 0] = row2.positions
  end

  defp random_booleans(n) do
    Enum.map(1..n, fn _ ->
      case :rand.uniform(2) do
        1 -> false
        2 -> true
      end
    end)
  end
end
