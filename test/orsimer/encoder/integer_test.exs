defmodule Orsimer.Encoder.IntegerTest do
  use ExUnit.Case

  setup do
    [
      type: Orsimer.Type.Integer.new()
    ]
  end

  test "encodes integers in direct signed encoding", %{type: type} do
    integers = random_numbers(100_000)

    [result] = Orsimer.Encoder.encode(type, integers, signed?: true)

    assert result.column == 0

    actual =
      Keyword.get(result.data_streams, :DATA)
      |> Stream.unfold(fn
        <<>> -> nil
        binary -> Orsimer.RLEv2.Integer.Direct.decode(binary, true)
      end)
      |> Enum.to_list()
      |> List.flatten()

    assert actual == integers
  end

  test "encodes integers into DATA and PRESENT streams when nil is in list", %{type: type} do
    integers = random_numbers(1_000, nil?: true)

    [result] = Orsimer.Encoder.encode(type, integers, signed?: true)

    present_stream = Keyword.get(result.data_streams, :PRESENT)
    data_stream = Keyword.get(result.data_streams, :DATA)

    actual =
      Stream.unfold(data_stream, fn
        <<>> -> nil
        binary -> Orsimer.RLEv2.Integer.Direct.decode(binary, true)
      end)
      |> Enum.to_list()
      |> List.flatten()

    booleans =
      Stream.unfold(present_stream, fn
        <<>> -> nil
        binary -> Orsimer.RLE.Boolean.decode(binary)
      end)
      |> Enum.to_list()
      |> List.flatten()

    expected_booleans = Enum.map(integers, fn
      nil -> false
      _ -> true
    end)

    assert actual == Enum.reject(integers, fn i -> i == nil end)
    assert length(expected_booleans) == length(booleans)
  end

  test "encode will create row index entries", %{type: type} do
    integers = random_numbers(22137)

    [result] = Orsimer.Encoder.encode(type, integers, signed?: true)

    [{:DATA, binary_stream}] = result.data_streams
    row_indexes = result.index.entry
    assert 3 == Enum.count(row_indexes)

    [0, start_one, 0] = Enum.at(row_indexes, 0) |> Map.get(:positions)
    [0, start_two, consume_two] = Enum.at(row_indexes, 1) |> Map.get(:positions)
    [0, start_three, consume_three] = Enum.at(row_indexes, 2) |> Map.get(:positions)

    first_group =
      binary_part(binary_stream, start_one, start_two - start_one)
      |> decode()

    second_group =
      binary_part(binary_stream, start_two, start_three - start_two)
      |> decode()

    third_group =
      binary_part(binary_stream, start_three, byte_size(binary_stream) - start_three)
      |> decode()

    assert first_group ++ Enum.take(second_group, consume_two) == Enum.take(integers, 10_000)

    assert Enum.drop(second_group, consume_two) ++ Enum.take(third_group, consume_three) ==
             Enum.slice(integers, 10_000..19_999)

    assert Enum.drop(third_group, consume_three) == Enum.drop(integers, 20_000)
  end

  defp random_numbers(n, opts \\ []) do
    Enum.map(1..n, fn _ ->
      random_number(opts)
    end)
  end

  defp random_number(opts \\ []) do
    max = Keyword.get(opts, :max, 1_000_000)
    nils? = Keyword.get(opts, :nil?, false)

    nil? = :rand.uniform(10) == 1

    case nil? && nils? do
      true -> nil
      false -> :rand.uniform(max)
    end
  end

  defp decode(binary) do
    Orsimer.Decoder.decode(Orsimer.Type.Integer.new(), [DATA: binary], signed?: true)
  end

end
