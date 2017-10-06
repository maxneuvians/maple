defmodule Maple do
  @moduledoc """
  The purpose of this module is to parse a GraphQL schema and to dynamically create
  easy to use client code functions at compile time with which a user can execute queries and
  mutations on a GraphQL endpoint.

  The module is built in such a way that you can pass it it the string name of an
  adapter module. Please take a look at `Maple.Behaviours.Adapter` for the expected
  behaviour. For an example and the default implementation, please refer to
  `Maple.Client`.

  Note: The module currently includes commented out, experimental code to create structs
  from the complex type definitions in a GraphQL schema.
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
    quote do
      import Maple
    end
  end

  defmacro generate_graphql_functions(adapter \\ "Elixir.Maple.Client") do
    adapter = String.to_atom(adapter)

    schema =
      adapter
      |> apply(:schema, [])
      |> Map.get("__schema")

    mutation_type_name = schema["mutationType"]["name"]
    query_type_name = schema["queryType"]["name"]

    schema["types"]
    |> Enum.reduce([], fn type, acc ->
      cond do

        type["name"] == mutation_type_name ->

          #Create mutation functions
          acc ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              Helpers.generate_mutation(function, adapter)
            end)

        type["name"] == query_type_name ->

          #Create query functions
          acc ++
            Enum.map(type["fields"], fn func ->
              function = Helpers.assign_function_params(func)
              # Check if we can create a query function with /1 when there are no required params
              if length(function[:required_params]) == 0 do
                [
                  Helpers.generate_one_arity_query(function, adapter),
                  Helpers.generate_two_arity_query(function, adapter)
                ]
              else
                [Helpers.generate_two_arity_query(function, adapter)]
              end
          end)

        #!Enum.member?(@known_types, type["name"]) && type["fields"] ->
        #  # Create structs
        #   acc ++
        #     quote do
        #       defmodule unquote(Module.concat(["Maple", "Types", type["name"]])) do
        #         defstruct Enum.map(unquote(Macro.escape(type["fields"])), &(String.to_atom(&1["name"])))
        #       end
        #   end

        true -> acc
      end
    end)
  end
end
