defmodule Maple.HttpTestAdapter do

  @behaviour Maple.Behaviours.HttpAdapter

  def mutate(string, %{}) do
    Maple.WebsocketTestAdapter.trigger_callback("Some result")
  end

  def query("{listWidgets{id}}", %{}) do
    %{"listWidgets" => [%{"id" => "foo"}, %{"id" => "bar"}]}
  end

  def query(string, %{}) do
    string
  end

  def schema() do
    File.read!("test/data/schema.json")
    |> Poison.decode!
  end
end
