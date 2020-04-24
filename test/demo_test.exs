defmodule DemoTest do
  use ExUnit.Case
  use Divo

  test "stuffy" do
    session =
      Prestige.new_session(
        url: "http://localhost:8080",
        user: "testing",
        catalog: "hive",
        schema: "default"
      )

    assert {:ok, _} = Prestige.execute(session, "CREATE TABLE users(name varchar, age integer, alive boolean)")

    data =
      Enum.map(1..3, fn i ->
        %{"name" => "joe", "age" => random_number(), "alive" => random_boolean(i)}
      end)
      |> Enum.map(fn row ->
        "('#{row["name"]}', #{row["age"]}, #{row["alive"]})"
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
    rem(i,2) == 0
  end
end
