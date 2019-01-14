defmodule Maple do
  @moduledoc """
  The purpose of this module is to parse a GraphQL schema and to dynamically create
  easy to use client code functions at compile time with which a user can execute queries and
  mutations on a GraphQL endpoint.

  The module takes options from the configuration:

  ```
  config :maple,
    http_adapter: Maple.Clients.Http,
    websocket_adapter: Maple.Clients.WebsocketApollo
  ```

  - `:http_adapter` - The default HTTP adapter for completing transactions against the GraphQL
  server. Default is: `Maple.Clients.Http`

  - `:websocket_adapter` - The default Websocket adapter for completing transactions against the GraphQL
  server using websockets. Default is: `Maple.Clients.WebsocketApollo`
  """

  alias Maple.{Generators, Helpers}

  defmacro __using__(_vars) do

    options = [
      http_adapter:  Application.get_env(:maple, :http_adapter, Maple.Clients.Http),
      websocket_adapter: Application.get_env(:maple, :websocket_adapter, Maple.Clients.WebsocketApollo)
    ]

    schema =
      options[:http_adapter]
      |> apply(:schema, [])
      |> Map.get("__schema")

    mutation_type_name = schema["mutationType"]["name"]
    query_type_name = schema["queryType"]["name"]
    subscription_type_name = schema["subscriptionType"]["name"]

    schema["types"]
    |> Enum.reduce([], fn type, ast ->
      cond do

        type["name"] == mutation_type_name ->

          #Create mutation functions
          ast ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              Generators.mutation(function, options[:http_adapter])
            end)

        type["name"] == query_type_name ->

          #Create query functions
          ast ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              [Generators.query(function, options[:http_adapter])]
            end)

        type["name"] == subscription_type_name ->

          #Create subscription functions
          ast ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              Generators.subscription(function, options[:websocket_adapter])
            end)

        !Enum.member?(Maple.Constants.types(), type["name"]) && type["fields"] ->
          # Create structs
          ast ++
           [quote do
             defmodule unquote(Module.concat(["Maple", "Types", type["name"]])) do
               defstruct Enum.map(unquote(Macro.escape(type["fields"])), &(String.to_atom(&1["name"])))
             end
           end]

        true -> ast
      end
    end)
  end
end
