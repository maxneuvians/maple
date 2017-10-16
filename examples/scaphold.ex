defmodule Maple.Examples.Scaphold.Config do
  Application.put_env(:maple, :api_url, "https://us-west-2.api.scaphold.io/graphql/maple")
  Application.put_env(:maple, :wss_url, "wss://us-west-2.api.scaphold.io/graphql/maple?Authorization=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJraW5kIjoic2NhcGhvbGQuc3VwZXJ1c2VyIiwiZXhwIjo4NjQwMDAwMDAwMDAwMDAwLCJpYXQiOjE1MDgxMDc0NzUsImF1ZCI6Ikp0Z2Z5WklRMnBKajlySThFOWU2MTdoUWNrMFJueEFuIiwiaXNzIjoiaHR0cHM6Ly9zY2FwaG9sZC5hdXRoMC5jb20vIiwic3ViIjoiZTI0MDdiOWItM2NiZi00MGZhLTliN2QtY2YyY2EwMDY4YTYyIn0.s_uMWwk6AWiNMzvHd6DtIumju2jRK0wdlh0c56v82_w")
end

defmodule Maple.Examples.Scaphold do
  @moduledoc """
  Demonstation code for a Scaphold.io API - sepcifically the subscription component.
  Scaphold uses the legacy websocket protocol `graphql-subscriptions`.

  Scaphold uses a JWT token in a GET param to authorize against the API. You can get this token from the settings in your
  Scaphold API.

  Example Interaction:
  ```
  iex(1)> Maple.Examples.Scaphold.subscribe_to_post(%{mutations: ["createPost"]}, "mutation value {id content title}", &Maple.Examples.Scaphold.result/1)

  18:40:22.932 [info]  Connected!
  :ok
  18:40:23.432 [info]  Successful subscription

  iex(2)> Maple.Examples.Scaphold.create_post(%{input: %{title: "Hello", content: "World"}},"id")

  18:45:24.977 [info]  Received subscription data
  %{"data" => %{"subscribeToPost" => %{"mutation" => "createPost",
      "value" => %{"content" => "World", "id" => "UG9zdDoxOA==",
        "title" => "Hello"}}}}

 %Maple.Response{body: %{"createPost" => %{"changedPost" => %{"id" => "UG9zdDoxOA=="}}},
 status: 200}
  ```
  """

  use Maple
  generate_graphql_functions(websocket_adapter: :"Elixir.Maple.Clients.WebsocketApolloLegacy")

  def result(data), do: IO.inspect data
end
