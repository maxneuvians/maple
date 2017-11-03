use Mix.Config

config :maple,
  build_type_structs: true,
  http_adapter: Maple.HttpTestAdapter,
  websocket_adapter: Maple.WebsocketTestAdapter
