defmodule Maple.HttpTestAdapter do

  @behaviour Maple.Behaviours.HttpAdapter

  def mutate(string, %{}, options) do
    Maple.WebsocketTestAdapter.trigger_callback("Some result")
  end

  def query("{listWidgets{id}}", %{}, options) do
    %{"listWidgets" => [%{"id" => "foo"}, %{"id" => "bar"}]}
  end

  def query(string, %{}, options) do
    string
  end

  def schema() do
    File.read!("test/data/schema.json")
    |> Poison.decode!
  end
end
