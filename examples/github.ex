defmodule Maple.Examples.Github.Config do
  Application.put_env(:maple, :api_url, "https://api.github.com/graphql")
  Application.put_env(:maple, :token, "TOKEN")
end

defmodule Maple.Examples.Github do
  use Maple
  generate_graphql_functions()
end
