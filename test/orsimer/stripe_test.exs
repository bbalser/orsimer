defmodule Orsimer.StripeTest do
  use ExUnit.Case

  describe "create" do
    test "will create an entire stripe including footer and compression" do
     type =
        Orsimer.Type.Struct.new(
          children: [
            Orsimer.Type.Integer.new(name: "id"),
            Orsimer.Type.String.new(name: "name")
          ]
        )

      data = [
       %{"id" => 100, "name" => "steve"},
       %{"id" => 101, "name" => "fred"}
      ]

      {binary, %Orc.Proto.StripeInformation{} = info, stats} = Orsimer.Stripe.create(type, data)

      IO.inspect(info, label: "stripe information")

      footer_start = info.indexLength + info.dataLength
      footer_bytes = binary_part(binary, footer_start, info.footerLength)

      %Orc.Proto.StripeFooter{} = footer =
        footer_bytes
        |> Orsimer.Compression.decompress()
        |> Orc.Proto.StripeFooter.decode()

      IO.inspect(footer, label: "footer")

      integers = binary_part(binary, 0, 7)

      Orsimer.Compression.decompress(integers)
      |> Orsimer.RLEv2.Integer.Direct.decode(true)
      |> Enum.each(&IO.puts/1)

      lengths = binary_part(binary, 7, 6) |> Orsimer.Compression.decompress()
      data = binary_part(binary, 7 + 6, 12) |> Orsimer.Compression.decompress()

      Orsimer.RLEv2.String.Direct.decode(lengths, data)
      |> IO.inspect(label: "names")

    end
  end
end
