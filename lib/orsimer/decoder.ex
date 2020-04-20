defmodule Orsimer.Decoder do
  @callback decode(Orsimer.streams(), keyword) :: list()
  @callback decode(Orsimer.streams()) :: list()
end
