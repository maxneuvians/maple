defmodule MapleTest do
  use ExUnit.Case
  require Logger
  import ExUnit.CaptureLog

  test "creates struct from object types in schema" do
    assert Maple.Types.Widget.__struct__
    assert Map.has_key?(Maple.Types.Widget.__struct__, :id)
    assert Map.has_key?(Maple.Types.Widget.__struct__, :name)
  end

  test "creates query functions with non-mandetory params" do
    assert :erlang.function_exported(MapleTest.Client, :list_widgets, 1)
    assert :erlang.function_exported(MapleTest.Client, :list_widgets, 2)
    assert :erlang.function_exported(MapleTest.Client, :list_widgets, 3)
  end

  test "creates query functions with mandatory params" do
    assert :erlang.function_exported(MapleTest.Client, :widget, 2)
    assert MapleTest.Client.widget(%{}, "") == {:error, "Query is missing the following required params: id"}
  end

  test "creates mutation functions" do
    assert :erlang.function_exported(MapleTest.Client, :create_widget, 2)
    assert :erlang.function_exported(MapleTest.Client, :create_widget, 3)
  end

  test "creates subscription functions" do
    assert :erlang.function_exported(MapleTest.Client, :subscribe_to_widget, 3)
  end

  test "allows for a callback to a subscription" do
    assert capture_log(fn ->
      MapleTest.Client.subscribe_to_widget(%{filter: "bar"}, "id", &Logger.info/1 )
      MapleTest.Client.create_widget(%{id: "foo", name: "bar"}, "id")
    end) =~ "Some result"
  end

  test "parses the result of a query" do
    assert MapleTest.Client.list_widgets("id") == %{"listWidgets" => [%{"id" => "foo"}, %{"id" => "bar"}]}
  end

  test "allows for the passing of options" do
    assert MapleTest.Client.list_widgets("id", [headers: %{foo: :bar}]) == %{foo: :bar}
    assert MapleTest.Client.list_widgets(%{}, "id", [headers: %{foo: :bar}]) == %{foo: :bar}
  end

  test "logs a warning if function is deprecated" do
    assert capture_log(fn ->
      assert MapleTest.Client.dep_list_widgets("id")
    end) =~ "Deprecation warning"
  end

  test "creates automatic documentation for a schema" do
    assert Code.get_docs(MapleTest.Client, :docs)
  end
end
