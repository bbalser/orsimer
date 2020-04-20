defmodule Orsimer.RLEv2.IntegerTest do
  use ExUnit.Case

  test "will encode a list of integers in direct encoding" do
    integers = random_numbers(4367)

    {_, streams} = Orsimer.RLEv2.Integer.encode(integers, signed?: true)
    decoded = Orsimer.RLEv2.Integer.decode(streams, signed?: true)

    assert decoded == integers
  end

  test "encode will create row index entries" do
    integers = random_numbers(22137)

    {row_index, [{:DATA, binary_stream}]} = Orsimer.RLEv2.Integer.encode(integers, signed?: true)

    row_indexes = row_index.entry
    assert 3 == Enum.count(row_indexes)

    [0, start_one, 0] = Enum.at(row_indexes, 0) |> Map.get(:positions)
    [0, start_two, consume_two] = Enum.at(row_indexes, 1) |> Map.get(:positions)
    [0, start_three, consume_three] = Enum.at(row_indexes, 2) |> Map.get(:positions)

    first_group =
      binary_part(binary_stream, start_one, start_two - start_one)
      |> (fn b -> [{:DATA, b}] end).()
      |> Orsimer.RLEv2.Integer.decode(signed?: true)

    second_group =
      binary_part(binary_stream, start_two, start_three - start_two)
      |> (fn b -> [{:DATA, b}] end).()
      |> Orsimer.RLEv2.Integer.decode(signed?: true)

    third_group =
      binary_part(binary_stream, start_three, byte_size(binary_stream) - start_three)
      |> (fn b -> [{:DATA, b}] end).()
      |> Orsimer.RLEv2.Integer.decode(signed?: true)

    assert first_group ++ Enum.take(second_group, consume_two) == Enum.take(integers, 10_000)

    assert Enum.drop(second_group, consume_two) ++ Enum.take(third_group, consume_three) ==
             Enum.slice(integers, 10_000..19_999)

    assert Enum.drop(third_group, consume_three) == Enum.drop(integers, 20_000)
  end

  defp random_numbers(n) do
    Enum.map(1..n, fn _ -> :rand.uniform(1_000_000) end)
  end
end
