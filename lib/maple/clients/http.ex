defmodule Maple.Clients.Http do
  @moduledoc """
  Implements an adapter to resolve the GraphQL mutations and queries against a
  remote server using the Tesla HTTP client.

  You could write your own adapter as long as it conforms to the
  `Maple.Behaviours.HttpAdapter` behaviour.
  """
  @behaviour Maple.Behaviours.HttpAdapter

  @doc """
  Takes a GraphQL mutation string and a map of parameters
  and executes it against a remove server
  """
  @spec mutate(String.t, map(), list()) :: %Maple.Response{}
  def mutate(string, params, options) do
    execute("mutation " <> string, params, options)
  end

  @doc """
  Takes a GraphQL query string and a map of parameters
  and executes it against a remove server
  """
  @spec query(String.t, map(), list()) :: %Maple.Response{}
  def query(string, params, options) do
    execute("query " <> string, params, options)
  end

  @doc """
  Returns the introspection query of a remote
  GraphQL server
  """
  @spec schema() :: map()
  def schema() do
    "query IntrospectionQuery {__schema {queryType {name} mutationType {name} subscriptionType {name} types {...FullType} directives {name description locations args {...InputValue}}}} fragment FullType on __Type {kind name description fields(includeDeprecated: true) {name description args {...InputValue} type {...TypeRef} isDeprecated deprecationReason} inputFields {...InputValue} interfaces {...TypeRef} enumValues(includeDeprecated: true) {name description isDeprecated deprecationReason} possibleTypes {...TypeRef}} fragment InputValue on __InputValue {name description type {...TypeRef} defaultValue} fragment TypeRef on __Type {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name}}}}}}}}"
    |> execute(%{}, [])
    |> Map.get(:body)
  end

  @doc """
  Executes the GraphQL command against a remote server
  """
  @spec execute(String.t, map(), list()) :: %Maple.Response{}
  defp execute(string, params, options) do
    query =
      %{
        query: string,
        variables: params
      }
      |> Poison.encode!
    
    additional_headers = Keyword.get(options, :headers, %{})
    if Application.get_env(:maple, :additional_headers)  do
      additional_headers = Map.merge(Application.get_env(:maple, :additional_headers), additional_headers) 
    end

    Application.get_env(:maple, :api_url)
    |> Tesla.post(query, headers: headers(additional_headers))
    |> Maple.Response.parse
  end

  @doc """
  Returns a map of headers to make a request. Merges in any
  additional headers defined by the `:additional_headers`
  configuration option
  """
  @spec headers(list()) :: map()
  defp headers(additional_headers) do
    Map.merge(%{"Content-Type" =>"application/json", "User-Agent" =>"Maple GraphQL Client"}, additional_headers)
  end
end
