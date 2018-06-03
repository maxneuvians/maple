defmodule Maple.Examples.AbsintheLocal.Config do
  Application.put_env(:maple, :api_url, "http://localhost:4000/graphql")
end

defmodule Maple.Examples.AbsintheLocal do
  @moduledoc """
  Demonstation code for a local Absinthe Server. The below functions are abitrary
  and not defined by any spec or example.

  Example Interaction:
  ```
  iex(1)> Maple.Examples.AbsintheLocal.widget(%{id: "foo"}, "name")
  %Maple.Response{body: %{"widget" => %{"name" => "Foo"}}, status: 200}

  iex(2)> Maple.Examples.AbsintheLocal.by_index(%{index: 1}, "id")
  %Maple.Response{body: %{"byIndex" => %{"id" => "foo"}}, status: 200}
  ```
  """

  use Maple
end
