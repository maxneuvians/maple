defmodule Maple.Client do
  @behaviour Maple.Behaviours.Adapter

  def mutate(string) do
    execute("mutation " <> string)
  end

  def query(string) do
    execute("query " <> string)
  end

  def schema() do
    execute("query IntrospectionQuery {__schema {queryType {name} mutationType {name} subscriptionType {name} types {...FullType} directives {name description locations args {...InputValue}}}} fragment FullType on __Type {kind name description fields(includeDeprecated: true) {name description args {...InputValue} type {...TypeRef} isDeprecated deprecationReason} inputFields {...InputValue} interfaces {...TypeRef} enumValues(includeDeprecated: true) {name description isDeprecated deprecationReason} possibleTypes {...TypeRef}} fragment InputValue on __InputValue {name description type {...TypeRef} defaultValue} fragment TypeRef on __Type {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name ofType {kind name}}}}}}}}")
    |> Map.get(:body)
  end

  defp execute(string) do
    query = %{query: string} |> Poison.encode!
    Tesla.post(Application.get_env(:maple, :api_url), query, headers: headers())
    |> Maple.Response.parse
  end

  defp headers() do
    if(Application.get_env(:maple, :additional_headers)) do
      Map.merge(%{"Content-Type" =>"application/json", "User-Agent" =>"Maple GraphQL Client"}, Application.get_env(:maple, :additional_headers))
    else
      %{"Content-Type" =>"application/json", "User-Agent" =>"Maple GraphQL Client"}
    end
  end
end
