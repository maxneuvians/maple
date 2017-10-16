defmodule MapleTest.Client do
  require Maple
  Maple.generate_graphql_functions(
    build_type_structs: true,
    http_adapter: :"Elixir.Maple.HttpTestAdapter",
    websocket_adapter: :"Elixir.Maple.WebsocketTestAdapter"
  )
end
