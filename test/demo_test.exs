defmodule DemoTest do
  use ExUnit.Case
  use Divo

  setup do
    Process.sleep(5_000)

    :ok
  end

  test "stuffy" do
    session =
      Prestige.new_session(
        url: "http://localhost:8080",
        user: "testing",
        catalog: "hive",
        schema: "default"
      )

    assert {:ok, _} =
             Prestige.execute(
               session,
               "CREATE TABLE users(name varchar, age integer, alive boolean)"
             )

    data =
      Enum.map(1..22_000, fn i ->
        %{
          "name" => random_string(21),
          "age" => random_number(nil?: false),
          "alive" => random_boolean(i)
        }
      end)
      |> (fn data ->
            [head | tail] = data
            data = [%{head | "name" => nil} | tail]
          end).()
      |> Enum.map(fn row ->
        "(#{value(row["name"])}, #{value(row["age"])}, #{value(row["alive"])})"
      end)
      |> Enum.join(",")

    stmt = "INSERT INTO users(name, age, alive) VALUES#{data}"
    IO.inspect(stmt, label: "stmt")
    Prestige.execute!(session, stmt)

    orc_file =
      ExAws.S3.list_objects("kdp-cloud-storage", prefix: "hive-s3/users")
      |> ExAws.request!()
      |> get_in([:body, :contents])
      |> Enum.map(&Map.get(&1, :key))
      |> Enum.reject(&String.contains?(&1, ".placeholder"))
      |> List.first()

    ExAws.S3.download_file("kdp-cloud-storage", orc_file, "stuff.orc")
    |> ExAws.request!()
  end

  defp value(nil), do: "NULL"
  defp value(integer) when is_integer(integer), do: integer
  defp value(boolean) when is_boolean(boolean), do: boolean
  defp value(value), do: "'#{value}'"

  defp random_number(opts \\ []) do
    max = Keyword.get(opts, :max, 1_000)
    nils? = Keyword.get(opts, :nil?, true)

    nil? = :rand.uniform(10) == 1

    case nil? && nils? do
      true -> 'null'
      false -> :rand.uniform(max)
    end
  end

  defp random_boolean(i) do
    rem(i, 2) == 0
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
