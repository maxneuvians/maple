defmodule Maple.Examples.AbsinthLocal.Config do
  Application.put_env(:maple, :api_url, "http://localhost:4000/graphql")
end

defmodule Maple.Examples.AbsinthLocal do
  use Maple
  generate_graphql_functions()
end
