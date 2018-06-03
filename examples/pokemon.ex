defmodule Maple.Examples.Pokemon.Config do
  Application.put_env(:maple, :api_url, "https://graphql-pokemon.now.sh/")
end

defmodule Maple.Examples.Pokemon do
  @moduledoc """
  Demonstation code for the Pokemon demo.

  Example Interaction:
  ```
  iex(1)> Maple.Examples.Pokemon.pokemons(%{first: 5}, "name")
  %Maple.Response{body: %{"pokemons" => [%{"name" => "Bulbasaur"},
    %{"name" => "Ivysaur"}, %{"name" => "Venusaur"}, %{"name" => "Charmander"},
    %{"name" => "Charmeleon"}]}, status: 200}

  iex(2)> Maple.Examples.Pokemon.pokemon(%{name: "Bulbasaur"}, "evolutions{name}")
  %Maple.Response{body: %{"pokemon" => %{"evolutions" => [%{"name" => "Ivysaur"},
      %{"name" => "Venusaur"}]}}, status: 200}
  ```
  """
  use Maple
end
