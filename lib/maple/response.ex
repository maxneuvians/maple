defmodule Maple.Response do
  @moduledoc """
  This module parses a Tesla response and places it into a
  more convenient to use struct
  """
  defstruct body: %{}, status: nil

  @doc """
  Parses a successfull Tesla response
  """
  @spec parse(%Tesla.Env{}) :: %Maple.Response{}
  def parse(%{:status => 200, :body => body}) do
    %Maple.Response{
      body: parse_body(body),
      status: 200
    }
  end

  @doc """
  Parses a bad request Tesla response with a custom error
  """
  @spec parse(%Tesla.Env{}) :: %Maple.Response{}
  def parse(%{:status => 400, :body => body}) do
    %Maple.Response{
      body: parse_error(body),
      status: 400
    }
  end

  @doc """
  Parses an unauthorized Tesla response
  """
  @spec parse(%Tesla.Env{}) :: %Maple.Response{}
  def parse(%{:status => 401}) do
    %Maple.Response{
      body: "Unauthorized",
      status: 401
    }
  end

  @doc """
  Parses a forbidden Tesla response
  """
  @spec parse(%Tesla.Env{}) :: %Maple.Response{}
  def parse(%{:status => 403}) do
    %Maple.Response{
      body: "Forbidden",
      status: 403
    }
  end

  @doc """
  Parses a not found Tesla response
  """
  @spec parse(%Tesla.Env{}) :: %Maple.Response{}
  def parse(%{:status => 404}) do
    %Maple.Response{
      body: "URL not found",
      status: 404
    }
  end

  @doc """
  Parses an generic error response
  """
  @spec parse(%Tesla.Env{}) :: %Maple.Response{}
  def parse(_) do
    %Maple.Response{
      body: "Internal server error",
      status: 500
    }
  end

  @doc """
  Parses the body from JSON and returns the value of data
  """
  @spec parse(String.t) :: map()
  defp parse_body(body) do
    body
    |> Poison.decode!
    |> get_in(["data"])
  end

  @doc """
  Parses the body from JSON and returns the value of error
  """
  @spec parse(String.t) :: map()
  defp parse_error(body) do
    body
    |> Poison.decode!
    |> get_in(["errors"])
  end
end
