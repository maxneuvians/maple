defmodule Maple.WebsocketTestAdapter do

  @behaviour Maple.Behaviours.WebsocketAdapter

  def start_link(_query, _params, callback) do
     Agent.start_link(fn -> %{callback: callback} end, name: __MODULE__)
     :ok
  end

  def trigger_callback(data) do
    callback = Agent.get(__MODULE__, fn %{callback: callback} ->
      apply(callback, [data])
    end)
  end
end
