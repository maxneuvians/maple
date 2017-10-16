defmodule Maple do
  @moduledoc """
  The purpose of this module is to parse a GraphQL schema and to dynamically create
  easy to use client code functions at compile time with which a user can execute queries and
  mutations on a GraphQL endpoint.

  The module takes a Keyword list with the following options:

  - `:build_type_structs` - Default is `false`. If set to `true` the macro will create
  structs for all the fields found in the introspection query. All types are namespaced into
  `Maple.Types.`

  - `:http_adapter` - The default HTTP adapter for completing transactions against the GraphQL
  server. Default is: `:"Elixir.Maple.Clients.Http"`

  - `:websocket_adapter` - The default Websocket adapter for completing transactions against the GraphQL
  server using websockets. Default is: `:"Elixir.Maple.Clients.WebsocketApollo"`
  """

  @default_options [
    build_type_structs: false,
    http_adapter: :"Elixir.Maple.Clients.Http",
    websocket_adapter: :"Elixir.Maple.Clients.WebsocketApollo"
  ]

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
    quote do
      import Maple
    end
  end

  defmacro generate_graphql_functions(options \\ []) do

    options = Keyword.merge(@default_options, options)

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
              # Check if we can create a query function with /1 when there are no required params
              if length(function[:required_params]) == 0 do
                [
                  Helpers.generate_one_arity_query(function, options[:http_adapter]),
                  Helpers.generate_two_arity_query(function, options[:http_adapter])
                ]
              else
                [Helpers.generate_two_arity_query(function, options[:http_adapter])]
              end
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
