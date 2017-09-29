defmodule Maple.Helpers do
  require Logger

  def assign_function_params(func) do
    %{
      name: func["name"],
      function_name: String.to_atom(Macro.underscore(func["name"])),
      required_params: get_required_params(func["args"]),
      param_types: get_param_types(func["args"]),
      deprecated: func["isDeprecated"],
      deprecated_reason: func["deprecationReason"],
      description: if(func["description"] == nil, do: "No description available", else: func["description"])
    }
  end

  def deprecated?(true, name, reason) do
    Logger.warn("Deprecation warning - function #{name} is deprecated for the following reason: #{reason}.")
  end
  def deprecated?(false, _, _), do: nil

  def find_missing(params, required_params) do
    required_params
    |> Enum.reduce([], fn key, list ->
      unless Enum.member?(Map.keys(params), key), do: list ++ [key], else: list
    end)
  end

  def get_param_types(args) do
    args
    |> Enum.reduce(%{}, fn arg, c ->
      Map.put(c, arg["name"], arg["type"]["ofType"]["name"])
    end)
  end

  def get_required_params(args) do
    args
    |> Enum.filter(&(&1["type"]["kind"] == "NON_NULL"))
    |> Enum.map(&(String.to_atom(&1["name"])))
  end

  def join_params(params, param_types) do
    params
    |> Enum.map(fn {k, v} ->
      "#{k}: #{cast_type(k, v, param_types)}"
    end)
    |> Enum.join(", ")
  end

  defp cast_type(key, value, types) do
    case types[Atom.to_string(key)] do
      "ID" -> "\"#{value}\""
      "String" -> "\"#{value}\""
      _ -> value
    end
  end

end
