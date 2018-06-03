defmodule Maple.Examples.Shopify.Config do
  Application.put_env(:maple, :api_url, "https://verge-studios.myshopify.com/api/graphql")
  Application.put_env(:maple, :additional_headers, %{"X-Shopify-Storefront-Access-Token" => "TOKEN"})
end

defmodule Maple.Examples.Shopify do
  @moduledoc """
  Demonstation code for the GitHub GraphQL API. Be sure to create a Token for Shopify and replace the
  TOKEN value in the above configutation.

  Example Interaction:
  ```
  iex(1)> Maple.Examples.Shopify.shop("name")
  %Maple.Response{body: %{"shop" => %{"name" => "Neuvians Innovation Inc."}}, status: 200}

  iex(2)> Maple.Examples.Shopify.shop("{shop{products(first: 1){edges{node{id}}}}}")
  %Maple.Response{body: %{"shopy" => %{"products" => %{ "edges" => %{"node" => %{"handle" => "periodic-table-of-weapons-poster"}}}}}, status: 200}
  ```
  """
  use Maple
end
