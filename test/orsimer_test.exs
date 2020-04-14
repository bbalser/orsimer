defmodule OrsimerTest do
  use ExUnit.Case

  test "write simple file" do

    schema = [
      Orsimer.Integer.new(name: "id"),
      Orsimer.String.new(name: "name")
    ]

    Orsimer.write(schema, [%{"id" => 3, "name" => "shannon"}, %{"id" => 4, "name" => "amanda"}])

    IO.inspect(binary,label: "done?")
  end
end
