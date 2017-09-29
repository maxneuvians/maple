defmodule Maple.Response do
  defstruct body: %{}, status: nil

  def parse(%{:status => 200, :body => body}) do
    %Maple.Response{
      body: parse_body(body),
      status: 200
    }
  end

  def parse(%{:status => 400, :body => body}) do
    %Maple.Response{
      body: parse_error(body),
      status: 400
    }
  end

  def parse(%{:status => 401}) do
    %Maple.Response{
      body: "Unauthorized",
      status: 401
    }
  end

  def parse(%{:status => 403}) do
    %Maple.Response{
      body: "Forbidden",
      status: 403
    }
  end

  def parse(%{:status => 404}) do
    %Maple.Response{
      body: "URL not found",
      status: 404
    }
  end

  defp parse_body(body) do
    Poison.decode!(body)
    |> get_in(["data"])
  end

  defp parse_error(body) do
    Poison.decode!(body)
    |> get_in(["errors"])
  end

  defp strip_namespace(map) do
    Map.values(map)
    |> List.first
  end
end
