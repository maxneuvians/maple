defmodule Maple.HttpTestAdapter do

  @behaviour Maple.Behaviours.HttpAdapter

  def mutate(_string, %{}, _options) do
    Maple.WebsocketTestAdapter.trigger_callback("Some result")
  end

  def query(_params, _fields, [headers: headers]) do
    headers
  end

  def query("{listWidgets{id}}", %{}, _options) do
    %Maple.Response{
      body: %{"listWidgets" => [%{"id" => "foo"}, %{"id" => "bar"}]},
      status: 200
    }
  end

  def query(string, %{}, _options) do
    string
  end

  def schema() do
    File.read!("test/data/schema.json")
    |> Poison.decode!
  end
end
