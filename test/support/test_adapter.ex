defmodule Maple.TestAdapter do

  def mutate(string) do
    string
  end

  def query("{listWidgets{id}}") do
    %{"listWidgets" => [%{"id" => "foo"}, %{"id" => "bar"}]}
  end

  def query(string) do
    string
  end

  def schema() do
    File.read!("test/data/schema.json")
    |> Poison.decode!
  end
end
