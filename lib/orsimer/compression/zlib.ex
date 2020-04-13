defmodule Orsimer.Compression.Zlib do

  def zip(input) do
    :zlib.zip(input)
  end

  def unzip(input) do
    :zlib.unzip(input)
  end
end
