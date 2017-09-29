defmodule Maple.Examples.Shopify.Config do
  Application.put_env(:maple, :api_url, "https://verge-studios.myshopify.com/api/graphql")
  Application.put_env(:maple, :additional_headers, %{"X-Shopify-Storefront-Access-Token" => "TOKEN"})
end

defmodule Maple.Examples.Shopify do
  use Maple
  generate_graphql_functions()
end
