defmodule Maple.Behaviours.WebsocketAdapter do
  @moduledoc """
  Defines behaviour for a websocket adapter to query a GraphQL server
  """

  @callback start_link(any, any, function) :: any

end
