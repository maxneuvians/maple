defmodule MapleTest.Client do
  require Maple
  Maple.generate_graphql_functions("Elixir.Maple.TestAdapter")
end
