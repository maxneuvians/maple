defmodule Maple.Helpers do
  @moduledoc """
  Helper functions to create the dybamic function in the macro. Helps
  keep the code somewhat clean and maintainable
  """
  require Logger

  @doc """
  Creates a custom map out of the parsed function data which is easier
  to work with when creating custom functions.
  """
  @spec assign_function_params(map()) :: map()
  def assign_function_params(func) do
    %{
      name: func["name"],
      function_name: String.to_atom(Macro.underscore(func["name"])),
      required_params: get_required_params(func["args"]),
      param_types: get_param_types(func["args"]),
      deprecated: func["isDeprecated"],
      deprecated_reason: func["deprecationReason"],
      description: generate_help(func)
    }
  end

  @doc """
  Creates a string to interpolate into the query or mutation that represents the
  variables defined in the variables dictionary. Ex. `id: $id`
  """
  @spec declare_params(map()) :: String.t
  def declare_params(params) do
    params
    |> Enum.map(fn {k, _v} ->
      "#{k}: $#{k}"
    end)
    |> Enum.join(", ")
  end

  @doc """
  Declares all the variables and their types that will be used inside the specific
  function
  """
  @spec declare_variables(map(), map()) :: String.t
  def declare_variables(params, types) do
    params
    |> Enum.map(fn {k, _v} ->
      "$#{k}: #{types[Atom.to_string(k)]}!"
    end)
    |> Enum.join(", ")
  end

  @doc """
  Emits a log warning if the function has been marked deprecared
  """
  @spec deprecated?(boolean(), String.t, String.t) :: nil
  def deprecated?(true, name, reason) do
    Logger.warn("Deprecation warning - function #{name} is deprecated for the following reason: #{reason}.")
    nil
  end
  def deprecated?(false, _, _), do: nil

  @doc """
  Finds all parameters that are missing from the required parameters list
  """
  @spec find_missing(map(), list()) :: list()
  def find_missing(params, required_params) do
    required_params
    |> Enum.reduce([], fn key, list ->
      if Enum.member?(Map.keys(params), key), do: list, else: list ++ [key]
    end)
  end

  @doc """
  Takes the data for a mutation function and an adapter and creates the AST that calls
  the mutation function on the adapter with the passed params and fields
  """
  @spec generate_mutation(map(), atom()) :: tuple()
  def generate_mutation(function, adapter) do
    quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do
      def unquote(f[:function_name])(params, fields, options \\ []) do
        missing = Maple.Helpers.find_missing(params, unquote(f[:required_params]))
        Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
        if missing != [] do
          {:error, "Mutation is missing the following required params: #{Enum.join(missing, ", ")}"}
        else
          mutation = """
            #{unquote(f[:name])}#{if(length(Map.keys(params)) > 0, do: "(#{Maple.Helpers.declare_variables(params, unquote(Macro.escape(f[:param_types])))})")}
            {
              #{unquote(f[:name])}(#{Maple.Helpers.declare_params(params)})
                {
                  #{fields}
                }
            }
          """
          mutation
            |> String.replace("\n", "")
            |> String.replace(" ", "")
          apply(unquote(adapter), :mutate, [mutation, params, options])
        end
      end
    end
  end

  @doc """
  Takes the data for a query function and an adapter and creates the AST that calls
  the query function on the passed adapter with the passed parameters and fields
  """
  @spec generate_two_arity_query(map(), atom()) :: tuple()
  def generate_two_arity_query(function, adapter) do
    quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do
      def unquote(f[:function_name])(params_or_fields, fields_or_options \\ [], options \\ []) do
        if is_map(params_or_fields) do
          params = params_or_fields
          fields = fields_or_options
          missing = Maple.Helpers.find_missing(params, unquote(f[:required_params]))
          Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:eprecated_reason]))
          if missing != [] do
            {:error, "Query is missing the following required params: #{Enum.join(missing, ", ")}"}
          else
            query = """
              #{unquote(f[:name])}#{if(length(Map.keys(params)) > 0, do: "(#{Maple.Helpers.declare_variables(params, unquote(Macro.escape(f[:param_types])))})")}
                {
                  #{unquote(f[:name])}
                    #{if(length(Map.keys(params)) > 0, do: "(#{Maple.Helpers.declare_params(params)})")}
                    {#{fields}}
                }
            """
            query =
              query
              |> String.replace("\n", "")
              |> String.replace(" ", "")
            apply(unquote(adapter), :query, [query, params, options])
          end
        else
          fields = params_or_fields
          options = fields_or_options
          Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
          query = "{#{unquote(f[:name])}{#{fields}}}"
          apply(unquote(adapter), :query, [query, %{}, options])
        end
      end
    end
  end

  @spec generate_subscription(map(), atom()) :: tuple()
  def generate_subscription(function, adapter) do
    quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do
      def unquote(f[:function_name])(params, fields, callback) do
        missing = Maple.Helpers.find_missing(params, unquote(f[:required_params]))
        Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
        if missing != [] do
          {:error, "Subscription is missing the following required params: #{Enum.join(missing, ", ")}"}
        else
          subscription = """
            subscription #{unquote(f[:name])}#{if(length(Map.keys(params)) > 0, do: "(#{Maple.Helpers.declare_variables(params, unquote(Macro.escape(f[:param_types])))})")}
            {
              #{unquote(f[:name])}(#{Maple.Helpers.declare_params(params)})
                {
                  #{fields}
                }
            }
          """
          subscription =
              subscription
              |> String.replace("\n", "")
              |> String.replace(" ", "")
          apply(unquote(adapter), :start_link, [subscription, params, callback])
        end
      end
    end
  end

  @doc """
  Returns a map of the GraphQL declared types for the arguments
  """
  @spec get_param_types(map()) :: map()
  def get_param_types(args) do
    args
    |> Enum.reduce(%{}, fn arg, c ->
      Map.put(c, arg["name"], determin_type(arg["type"]))
    end)
  end

  @doc """
  Returns all the parameters flagged as required
  """
  @spec get_required_params(map()) :: list()
  def get_required_params(args) do
    args
    |> Enum.filter(&(&1["type"]["kind"] == "NON_NULL"))
    |> Enum.map(&(String.to_atom(&1["name"])))
  end

  @doc """
  Determins the type when the type is not explicitly defined.
  Falls back on String type.
  """
  @spec determin_type(map()) :: String.t
  defp determin_type(type) do
    cond do
      empty?(type["ofType"])
        -> type["name"]
      type["kind"] == "LIST"
        -> "[#{determin_type(type["ofType"])}]"
      Map.has_key?(type["ofType"], "ofType")
        -> determin_type(type["ofType"])
      true
        -> "String"
    end
  end

  @doc """
  Checks if a string is empty
  """
  @spec empty?(String.t) :: boolean()
  defp empty?(nil), do: true
  defp empty?(_), do: false

  @doc """
  Creates a help string for a function
  """
  @spec generate_help(map()) :: String.t
  defp generate_help(func) do
    """
    #{if(func["description"], do: func["description"], else: "No description available")}
    \n
    """
    <>
    (func["args"]
    |> Enum.map(fn arg ->
      """
      Param name: #{arg["name"]}
      - Description: #{if(arg["description"], do: arg["description"], else: "No description ")}
      - Type: #{if(arg["type"]["ofType"]["name"], do: arg["type"]["ofType"]["name"], else: "Not defined")}
      - Required: #{if(arg["type"]["kind"] == "NON_NULL", do: "Yes", else: "No")}
      """
    end)
    |> Enum.join("\n"))
  end

end
