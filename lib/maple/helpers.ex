defmodule Maple.Helpers do
  @moduledoc """
  Helper functions to create the dybamic function in the macro. Helps
  keep the code somewhat clean and maintainable
  """
  require Logger

  def apply_type(response, func) do
    result = response[func[:name]]
    cond do
      is_list(result) ->
        result
        |> Enum.map(&(Kernel.struct(return_type(func[:type]), atomize_keys(&1))))
      true ->
        Kernel.struct(return_type(func[:type]), atomize_keys(result))
    end
  end

  @doc """
  Creates a custom map out of the parsed function data which is easier
  to work with when creating custom functions.
  """
  @spec assign_function_params(map()) :: map()
  def assign_function_params(func) do
    %{
      name: func["name"],
      arguments: func["args"],
      function_name: String.to_atom(Macro.underscore(func["name"])),
      required_params: get_required_params(func["args"]),
      param_types: get_param_types(func["args"]),
      deprecated: func["isDeprecated"],
      deprecated_reason: func["deprecationReason"],
      description: generate_help(func),
      type: determin_type(func["type"])
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
  Remove all the whitespaces from a string
  """
  @spec remove_whitespaces(String.t()) :: String.t()
  def remove_whitespaces(string) do
    string
    |> String.replace("\n", "")
    |> String.replace(" ", "")
  end

  def return_type(type) do
    type =
      type
      |> String.trim("[")
      |> String.trim("]")
    ["Maple", "Types", type] |> Module.concat() |> Kernel.struct()
  end

  def stringify_struct(obj) do
    keys =
      obj
      |> Map.keys()
      |> List.delete(:__struct__)
      |> Enum.join(",")
    "#{keys}"
  end

  defp atomize_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
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
      - Type: #{determin_type(arg["type"])}
      - Required: #{if(arg["type"]["kind"] == "NON_NULL", do: "Yes", else: "No")}
      """
    end)
    |> Enum.join("\n"))
  end

end
