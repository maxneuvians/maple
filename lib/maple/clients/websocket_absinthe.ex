defmodule Maple.Clients.WebsocketAbsinthe do
  @moduledoc false

  @behaviour Maple.Behaviours.WebsocketAdapter

  use WebSockex
  require Logger

  def start_link(_query, _params, _callback) do
    # Not yet implemented
  end
end
