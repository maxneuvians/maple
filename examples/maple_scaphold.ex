defmodule Maple.Examples.MapleScaphold.Config do
  Application.put_env(:maple, :api_url, "https://us-west-2.api.scaphold.io/graphql/maple")
end

defmodule Maple.Examples.MapleScaphold do
  use Maple
  generate_graphql_functions()
end
