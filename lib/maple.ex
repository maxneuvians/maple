defmodule Maple do
  @moduledoc """
  The purpose of this module is to parse a GraphQL schema and to dynamically create
  easy to use client code functions at compile time with which a user can execute queries and
  mutations on a GraphQL endpoint.

  The module takes options from the configuration:

  ```
  config :maple,
    build_type_structs: false,
    http_adapter: Maple.Clients.Http,
    websocket_adapter: Maple.Clients.WebsocketApollo
  ```

  - `:build_type_structs` - Default is `false`. If set to `true` the macro will create
  structs for all the fields found in the introspection query. All types are namespaced into
  `Maple.Types.`

  - `:http_adapter` - The default HTTP adapter for completing transactions against the GraphQL
  server. Default is: `Maple.Clients.Http`

  - `:websocket_adapter` - The default Websocket adapter for completing transactions against the GraphQL
  server using websockets. Default is: `Maple.Clients.WebsocketApollo`
  """

  @known_types ~w(
    __Directive
    __DirectiveLocation
    __EnumValue
    __Field
    __InputValue
    __Schema
    __Type
    Boolean
    Float
    ID
    Int
    String
  )

  alias Maple.Helpers

  defmacro __using__(_vars) do

    options = [
      build_type_structs: Application.get_env(:maple, :build_type_structs, false),
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
    |> Enum.reduce([], fn type, acc ->
      cond do

        type["name"] == mutation_type_name ->

          #Create mutation functions
          acc ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              Helpers.generate_mutation(function, options[:http_adapter])
            end)

        type["name"] == query_type_name ->

          #Create query functions
          acc ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              [Helpers.generate_two_arity_query(function, options[:http_adapter])]
            end)

        type["name"] == subscription_type_name ->

          #Create subscription functions
          acc ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              Helpers.generate_subscription(function, options[:websocket_adapter])
            end)

        !Enum.member?(@known_types, type["name"]) && type["fields"] && options[:build_type_structs] ->
          # Create structs
          acc ++
           [quote do
             defmodule unquote(Module.concat(["Maple", "Types", type["name"]])) do
               defstruct Enum.map(unquote(Macro.escape(type["fields"])), &(String.to_atom(&1["name"])))
             end
           end]

        true -> acc
      end
    end)
  end
end
