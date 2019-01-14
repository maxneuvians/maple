defmodule Maple.Generators do

  @doc """
  Takes the data for a mutation function and an adapter and creates the AST that calls
  the mutation function on the adapter with the passed params and fields
  """
  @spec mutation(map(), atom()) :: tuple()
  def mutation(function, adapter) do

    quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do

      @doc "Pass :function_type and :type to introspect function"
      def unquote(f[:function_name])(:function_type), do: :mutation
      def unquote(f[:function_name])(:type), do: Maple.Helpers.return_type(unquote(f[:type]))

      @doc f[:description]
      def unquote(f[:function_name])(params, fields \\ "", options \\ []) do
          missing = Maple.Helpers.find_missing(params, unquote(f[:required_params]))
          Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))

          if missing != [] do
            {:error, "Mutation is missing the following required params: #{Enum.join(missing, ", ")}"}
          else
            mutation = """
              #{unquote(f[:name])}#{if(length(Map.keys(params)) > 0, do: "(#{Maple.Helpers.declare_variables(params, unquote(Macro.escape(f[:param_types])))})")}
              {
                #{unquote(f[:name])}(#{Maple.Helpers.declare_params(params)})
                #{if(fields != "", do: "{#{fields}}")}
              }
            """
            apply(unquote(adapter), :mutate, [Maple.Helpers.remove_whitespaces(mutation), params, options])
          end
      end

    end
  end

  @doc """
  Takes the data for a query function and an adapter and creates the AST that calls
  the query function on the passed adapter with the passed parameters and fields
  """
  @spec query(map(), atom()) :: tuple()
  def query(function, adapter) do

    quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do

      def unquote(f[:function_name])(), do: unquote(f[:function_name])(Maple.Helpers.stringify_struct(Maple.Helpers.return_type(unquote(f[:type]))))

      @doc "Pass :function_type and :type to introspect function"
      def unquote(f[:function_name])(:function_type), do: :query
      def unquote(f[:function_name])(:type), do: Maple.Helpers.return_type(unquote(f[:type]))

      @doc f[:description]
      def unquote(f[:function_name])(params_or_fields, fields_or_options \\ [], options \\ []) do
        if is_map(params_or_fields) do
          params = params_or_fields
          fields = fields_or_options
          missing = Maple.Helpers.find_missing(params, unquote(f[:required_params]))
          Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
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
            apply(unquote(adapter), :query, [Maple.Helpers.remove_whitespaces(query), params, options])
          end
        else
          fields = params_or_fields
          options = fields_or_options
          Maple.Helpers.deprecated?(unquote(f[:deprecated]), unquote(f[:name]), unquote(f[:deprecated_reason]))
          case result = apply(unquote(adapter), :query, ["{#{unquote(f[:name])}{#{fields}}}", %{}, options]) do
            %{status: 200} ->
              Maple.Helpers.apply_type(result.body, unquote(Macro.escape(f)))
            _ ->
              result
          end
        end
      end

    end
  end

  @spec subscription(map(), atom()) :: tuple()
  def subscription(function, adapter) do

    quote bind_quoted: [adapter: adapter, f: Macro.escape(function)] do

      @doc "Pass :function_type and :type to introspect function"
      def unquote(f[:function_name])(:function_type), do: :subscription
      def unquote(f[:function_name])(:type), do: ["Maple", "Types", unquote(f[:type])] |> Module.concat() |> Kernel.struct()

      @doc f[:description]
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

end
