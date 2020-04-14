defmodule Orsimer.Stripe do
  @spec create(Orsimer.Type.t(), [%{required(String.t()) => term}]) ::
          {binary, Orc.Proto.StripeInformation.t(), [Orc.Proto.ColumnStatistics.t()]}
  def create(type, list) do
    {streams, binaries} = Orsimer.Type.streams(type, list)

    data_binary = Enum.join(binaries)

    footer =
      Orc.Proto.StripeFooter.new(streams: streams, columns: Orsimer.Type.column_encoding(type))
      |> Orc.Proto.StripeFooter.encode()
      |> Orsimer.Compression.compress()

    information =
      Orc.Proto.StripeInformation.new(
        indexLength: 0,
        dataLength: byte_size(data_binary),
        footerLength: byte_size(footer)
      )

    {data_binary <> footer, information, []}
  end
end
