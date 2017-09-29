defmodule Maple do
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
      apply(adapter, :schema, [])
      |> Map.get("__schema")

    mutationTypeName = schema["mutationType"]["name"]
    queryTypeName = schema["queryType"]["name"]

    schema["types"]
    |> Enum.map(fn type ->
      cond do

        type["name"] == mutationTypeName ->

          #Create mutation functions
          Enum.map(type["fields"], fn func ->
            function = Helpers.assign_function_params(func)
            quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do
              Module.add_doc(__MODULE__, 1, :def, {f[:function_name], 2}, [:params, :fields], f[:description])
              def unquote(f[:function_name])(params, fields) do
                missing = Helpers.find_missing(params, unquote(f[:required_params]))
                Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
                if missing != [] do
                  {:error, "Mutation is missing the following required params: #{Enum.join(missing, ", ")}"}
                else
                  mutation = """
                    {
                      #{unquote(f[:name])}(#{Helpers.join_params(params, unquote(Macro.escape(f[:param_types])))})
                        {
                          #{fields}
                        }
                    }
                  """
                  apply(unquote(adapter), :mutate, [mutation])
                end
              end
            end
          end)

        type["name"] == queryTypeName ->
          #Create query functions
          Enum.map(type["fields"], fn func ->
            function = Helpers.assign_function_params(func)

            # Check if we can create a query function with /1 when there are no required params
            functions = if(length(function[:required_params]) == 0) do
              [quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do
                Module.add_doc(__MODULE__, 1, :def, {f[:function_name], 1}, [:fields], f[:description])
                def unquote(f[:function_name])(fields) do
                  Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
                  query = "{#{unquote(f[:name])}{#{fields}}}"
                  apply(unquote(adapter), :query, [query])
                end
              end]
            else
              []
            end

            # Create regular query function with /2
            functions = functions ++ [quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do
              Module.add_doc(__MODULE__, 1, :def, {f[:function_name], 2}, [:params, :fields], f[:description])
              def unquote(f[:function_name])(params, fields) do
                missing = Helpers.find_missing(params, unquote(f[:required_params]))
                Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:eprecated_reason]))
                if missing != [] do
                  {:error, "Query is missing the following required params: #{Enum.join(missing, ", ")}"}
                else
                  query = """
                    {
                      #{unquote(f[:name])}
                        #{if(length(Map.keys(params)) > 0, do: "(#{Helpers.join_params(params, unquote(Macro.escape(f[:param_types])))})")}
                        {#{fields}}
                    }
                  """
                  apply(unquote(adapter), :query, [query])
                end
              end
            end]
            List.flatten(functions)
          end)

        #!Enum.member?(@known_types, type["name"]) && type["fields"] ->
        #  # Create structs
        #  quote do
        #    defmodule unquote(Module.concat(["Maple", "Types", type["name"]])) do
        #      defstruct Enum.map(unquote(Macro.escape(type["fields"])), &(String.to_atom(&1["name"])))
        #    end
        #  end

        true -> true
      end
    end)
    |> List.flatten
  end
end
