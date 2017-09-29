defmodule Maple.Examples.Pokemon.Config do
  Application.put_env(:maple, :api_url, "https://graphql-pokemon.now.sh/")
end

defmodule Maple.Examples.Pokemon do
  use Maple
  generate_graphql_functions()
end
