defmodule Maple.Client do
  @moduledoc """
  Implements an adapter to resolve the GraphQL mutations and queries against a
  remote server using the Tesla HTTP client. Ideally, you could write your own
  adapter as long as it conforms to the `Maple.Behaviours.Adapter` behaviour.
  """
  @behaviour Maple.Behaviours.Adapter

  @doc """
  Takes a GraphQL mutation string and a map of parameters
  and executes it against a remove server
  """
  @spec mutate(String.t, map()) :: %Maple.Response{}
  def mutate(string, params) do
    execute("mutation " <> string, params)
  end

  @doc """
  Takes a GraphQL query string and a map of parameters
  and executes it against a remove server
  """
  @spec query(String.t, map()) :: %Maple.Response{}
  def query(string, params) do
    execute("query " <> string, params)
  end

  @doc """
  Returns the introspection query of a remote
  GraphQL server
  """
  @spec schema() :: map()
  def schema() do
    "query IntrospectionQuery {__schema {queryType {name} mutationType {name} subscriptionType {name} types {...FullType} directives {name description locations args {...InputValue}}}} fragment FullType on __Type {kind name description fields(includeDeprecated: true) {name description args {...InputValue} type {...TypeRef} isDeprecated deprecationReason} inputFields {...InputValue} interfaces {...TypeRef} enumValues(includeDeprecated: true) {name description isDeprecated deprecationReason} possibleTypes {...TypeRef}} fragment InputValue on __InputValue {name description type {...TypeRef} defaultValue} fragment TypeRef on __Type {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name}}}}}}}}"
    |> execute()
    |> Map.get(:body)
  end

  @doc """
  Executes the GraphQL command against a remote server
  """
  @spec execute(String.t) :: %Maple.Response{}
  defp execute(string, params \\ %{}) do
    query =
      %{
        query: string,
        variables: params
      }
      |> Poison.encode!

    Application.get_env(:maple, :api_url)
    |> Tesla.post(query, headers: headers())
    |> Maple.Response.parse
  end

  @doc """
  Returns a map of headers to make a request. Merges in any
  additional headers defined by the `:additional_headers`
  configuration option
  """
  @spec headers() :: map()
  defp headers() do
    if Application.get_env(:maple, :additional_headers)  do
      Map.merge(%{"Content-Type" =>"application/json", "User-Agent" =>"Maple GraphQL Client"}, Application.get_env(:maple, :additional_headers))
    else
      %{"Content-Type" =>"application/json", "User-Agent" =>"Maple GraphQL Client"}
    end
  end
end
