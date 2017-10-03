defmodule MapleTest.Maple.ResponseTest do
  use ExUnit.Case

  alias Maple.Response

  test "returns a struct for 200 status code responses" do
    result = Response.parse(%{:status => 200, :body => "{\"data\": [\"Hello\"]}"})
    assert result.__struct__ == Maple.Response
    assert result.status == 200
    assert result.body == ["Hello"]
  end

  test "returns a struct for 400 status code responses" do
    result = Response.parse(%{:status => 400, :body => "{\"errors\": [\"Error\"]}"})
    assert result.__struct__ == Maple.Response
    assert result.status == 400
    assert result.body == ["Error"]
  end

  test "returns a struct for 401 status code responses" do
    result = Response.parse(%{:status => 401, :body => "{\"errors\": [\"Error\"]}"})
    assert result.__struct__ == Maple.Response
    assert result.status == 401
    assert result.body == "Unauthorized"
  end

  test "returns a struct for 403 status code responses" do
    result = Response.parse(%{:status => 403, :body => "{\"errors\": [\"Error\"]}"})
    assert result.__struct__ == Maple.Response
    assert result.status == 403
    assert result.body == "Forbidden"
  end

  test "returns a struct for 404 status code responses" do
    result = Response.parse(%{:status => 404, :body => "{\"errors\": [\"Error\"]}"})
    assert result.__struct__ == Maple.Response
    assert result.status == 404
    assert result.body == "URL not found"
  end

  test "returns a struct for 500 status code responses" do
    result = Response.parse(%{:status => 500, :body => "{\"errors\": [\"Error\"]}"})
    assert result.__struct__ == Maple.Response
    assert result.status == 500
    assert result.body == "Internal server error"
  end



end
