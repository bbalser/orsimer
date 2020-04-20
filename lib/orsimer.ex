defmodule Orsimer do

  @type stream_kind :: :ROW_INDEX | :PRESENT | :LENGTH | :DATA
  @type stream :: binary

  @type streams :: [{stream_kind, stream}]

  def write(schema, data) do



  end


  def to_bits(binary, list \\ [])

  def to_bits(<<>>, list) do
    Enum.reverse(list)
  end

  def to_bits(<<bit::size(1), rest::bitstring>>, list) do
    to_bits(rest, [bit | list])
  end
end
