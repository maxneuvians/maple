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
            name = func["name"]
            function_name = String.to_atom(Macro.underscore(name))
            required_keys = get_required_keys(func["args"])
            deprecated = func["isDeprecated"]
            deprecated_reason = func["deprecationReason"]
            description = if(func["description"] == nil, do: "No description available", else: func["description"])

            quote bind_quoted: [function_name: function_name, name: name, required_keys: required_keys, adapter: adapter, deprecated: deprecated, deprecated_reason: deprecated_reason, description: description] do
              Module.add_doc(__MODULE__, 1, :def, {function_name, 2}, [:params, :fields], description)
              def unquote(function_name)(params, fields) do
                missing = unquote(required_keys)
                |> Enum.reduce([], fn key, list ->
                  unless Enum.member?(Map.keys(params), key), do: list ++ [key], else: list
                end)
                if unquote(deprecated) do
                  require Logger
                  Logger.warn(
                    "Deprecation warning - function #{unquote(name)} is deprecated for the following reason: #{unquote(deprecated_reason)}"
                  )
                end
                if missing != [] do
                  {:error, "Mutation is missing the following required params: #{Enum.join(missing, ", ")}"}
                else
                  mutation = """
                    {
                      #{unquote(name)}(#{Enum.join(Enum.map(params, fn {k, v} -> "#{k}: \"#{v}\"" end), ", ")})
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
            name = func["name"]
            function_name = String.to_atom(Macro.underscore(name))
            required_keys = get_required_keys(func["args"])
            deprecated = func["isDeprecated"]
            deprecated_reason = func["deprecationReason"]
            description = if(func["description"] == nil, do: "No description available", else: func["description"])

            # Check if we can create a query function with /1 when there are no required params
            functions = if(length(required_keys) == 0) do

              [quote bind_quoted: [function_name: function_name, name: name, adapter: adapter, deprecated: deprecated, deprecated_reason: deprecated_reason, description: description] do
                Module.add_doc(__MODULE__, 1, :def, {function_name, 1}, [:fields], description)
                def unquote(function_name)(fields) do
                  if unquote(deprecated) do
                    require Logger
                    Logger.warn(
                      "Deprecation warning - function #{unquote(name)} is deprecated for the following reason: #{unquote(deprecated_reason)}"
                    )
                  end

                  query = "{#{unquote(name)}{#{fields}}}"
                  apply(unquote(adapter), :query, [query])
                end
              end]
            else
              []
            end

            # Create regular query function with /2
            functions = functions ++ [quote bind_quoted: [function_name: function_name, name: name, required_keys: required_keys, adapter: adapter, deprecated: deprecated, deprecated_reason: deprecated_reason, description: description] do
              Module.add_doc(__MODULE__, 1, :def, {function_name, 2}, [:params, :fields], description)
              def unquote(function_name)(params, fields) do
                missing = unquote(required_keys)
                |> Enum.reduce([], fn key, list ->
                  unless Enum.member?(Map.keys(params), key), do: list ++ [key], else: list
                end)
                if unquote(deprecated) do
                  require Logger
                  Logger.warn(
                    "Deprecation warning - function #{unquote(name)} is deprecated for the following reason: #{unquote(deprecated_reason)}"
                  )
                end
                if missing != [] do
                  {:error, "Query is missing the following required params: #{Enum.join(missing, ", ")}"}
                else
                  query = """
                    {
                      #{unquote(name)}
                        #{if(length(Map.keys(params)) > 0, do: "(#{Enum.join(Enum.map(params, fn {k, v} -> "#{k}: \"#{v}\"" end), ", ")})")}
                        {
                          #{fields}
                        }
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

  defp get_required_keys(args) do
    args
    |> Enum.filter(&(&1["type"]["kind"] == "NON_NULL"))
    |> Enum.map(&(String.to_atom(&1["name"])))
  end
end
