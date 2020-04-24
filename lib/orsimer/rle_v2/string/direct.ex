defmodule Orsimer.RLEv2.String.Direct do

  def encode(strings) do
    lengths = Enum.map(strings, &byte_size/1)

    {
      Orsimer.RLEv2.Integer.encode(lengths),
      Enum.join(strings)
    }
  end

  def decode(length_stream, data_stream) do
    Orsimer.RLEv2.Integer.decode([DATA: length_stream])
    |> Enum.map_reduce(data_stream, fn length, bytes ->
      <<value::binary-size(length), remaining::binary>> = bytes
      {value, remaining}
    end)
    |> elem(0)
  end
end
