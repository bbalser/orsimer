defmodule Orsimer.RLEv2.String.Direct do

  def encode(strings) do
    lengths = Enum.map(strings, &byte_size/1)

    {
      Orsimer.RLEv2.Integer.Direct.encode(lengths),
      Enum.join(strings)
    }
  end

  def decode(length_stream, data_stream) do
    Orsimer.RLEv2.Integer.Direct.decode(length_stream)
    |> Enum.reduce({data_stream, []}, fn length, {data, buffer} ->
      <<value::binary-size(length)-unit(8), remaining::binary>> = data
      {remaining, [value | buffer]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end
end
