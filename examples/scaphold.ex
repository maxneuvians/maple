defmodule Maple.Examples.Scaphold.Config do
  Application.put_env(:maple, :api_url, "https://us-west-2.api.scaphold.io/graphql/maple")
  Application.put_env(:maple, :wss_url, "wss://us-west-2.api.scaphold.io/graphql/maple?Authorization=YOUR_JWT_TOKEN")
  Application.put_env::maple, :websocket_adapter, Maple.Clients.WebsocketApolloLegacy)
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

  def result(data), do: IO.inspect data
end
