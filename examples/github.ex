defmodule Maple.Examples.Github.Config do
  Application.put_env(:maple, :api_url, "https://api.github.com/graphql")
  Application.put_env(:maple, :additional_headers, %{"Authorization" => "Bearer TOKEN"})
end

defmodule Maple.Examples.Github do
  @moduledoc """
  Demonstation code for the GitHub GraphQL API. Be sure to create a Bearer token for GitHub and replace the
  TOKEN value in the above configutation.

  Example Interaction:
  ```
  iex(1)> Maple.Examples.Github.viewer("login")
  %Maple.Response{body: %{"viewer" => %{"login" => "maxneuvians"}}, status: 200}

  iex(2)> Maple.Examples.Github.user(%{login: "maxneuvians"}, "id")
  %Maple.Response{body: %{"user" => %{"id" => "MDQ6VXNlcjg2NzMzNA=="}}, status: 200}
  ```
  """

  use Maple
end
