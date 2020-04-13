defmodule Orsimer.CompresstionTest do
  use ExUnit.Case
  use Placebo

  describe "compress" do
    test "adds compressed header and zips data" do
      fake_compressed_data = random_string(100_000)
      allow Orsimer.Compression.Zlib.zip(any()), return: fake_compressed_data
      input = random_string(100_001)

      output = Orsimer.Compression.compress(input)

      <<header::size(24), body::binary>> = output
      assert Base.encode16(<<header::size(24)>>, case: :lower) == "400d03"
      assert body == fake_compressed_data
    end

    test "add header marking original when compressed size is greater than original size" do
      fake_compressed_data = random_string(8)
      allow Orsimer.Compression.Zlib.zip(any()), return: fake_compressed_data
      input = random_string(5)

      output = Orsimer.Compression.compress(input)

      <<header::size(24), body::binary>> = output
      assert Base.encode16(<<header::size(24)>>, case: :lower) == "0b0000"
      assert body == input
    end
  end

  describe "decompress" do
    test "decompresses zipped data" do
      input = "one is the best number, two is the loneliest number"
      compressed_chunk = Orsimer.Compression.compress(input)

      assert input == Orsimer.Compression.decompress(compressed_chunk)
    end

    test "returns original data unmodified" do
      input = "one is the best number"
      compressed_chunk = Orsimer.Compression.compress(input)

      assert input == Orsimer.Compression.decompress(compressed_chunk)
    end
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
