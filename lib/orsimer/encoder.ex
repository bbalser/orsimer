defmodule Orsimer.Encoder do
  @callback encode(list(), keyword()) :: {Orc.Proto.RowIndex.t(), Orsimer.streams()}
  @callback encode(list()) :: {Orc.Proto.RowIndex.t(), Orsimer.streams()}
end
