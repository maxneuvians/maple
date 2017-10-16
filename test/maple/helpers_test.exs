defmodule MapleTest.Maple.HelpersTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias Maple.Helpers

  test "assign_function_params/1 returns a map with manipulated data" do
    data = %{
      "args" => [],
      "deprecationReason" => "This was a bad idea",
      "description" => nil,
      "isDeprecated" => true,
      "name" => "depListWidgets",
      "type" =>
        %{
          "kind" => "LIST",
          "name" => nil,
          "ofType" =>
            %{"kind" => "OBJECT",
            "name" => "Widget",
            "ofType" => nil
          }
        }
    }
    result = Helpers.assign_function_params(data)
    assert result.name == "depListWidgets"
    assert result.function_name == :dep_list_widgets
    assert result.required_params == []
    assert result.param_types == %{}
    assert result.deprecated == true
    assert result.deprecated_reason == "This was a bad idea"
    assert result.description == "No description available\n\n\n"
  end

  test "declare_params/1 creates a GraphQL param list" do
    data = %{id: "1", name: "Foo"}
    assert Helpers.declare_params(data) == "id: $id, name: $name"
  end

  test "declare_variables/2 creates a GraphQL variable list" do
    data = %{id: "1", name: "Foo"}
    types = %{"id" => "Integer", "name" => "String"}
    assert Helpers.declare_variables(data, types) == "$id: Integer!, $name: String!"
  end

  test "deprecated/3 logs a warning if function is deprecated" do
    assert capture_log(fn ->
      assert Helpers.deprecated?(true, "test", "test") == nil
    end) =~ "Deprecation warning"
  end

  test "find_missing/2 retuns a list of missing keys in parameter list" do
    required_params = [:id, :name]
    params = %{id: "Foo"}
    assert Helpers.find_missing(params, required_params) == [:name]
  end

  test "generate_mutation/2 returns a tuple with an AST for a passed function" do
    function = %{
      deprecated: false,
      deprecated_reason: nil,
      description: "Desc",
      function_name: :create_widget,
      name: "createWidget",
      param_types:
        %{
          "email" => nil,
          "id" => "ID",
          "name" => "String"
        },
      required_params: [:id, :name]
    }
    assert is_tuple(Helpers.generate_mutation(function, :adapter))
  end

  test "generate_one_arity_query/2 returns a tuple with an AST for a passed function" do
    function = %{
      deprecated: false,
      deprecated_reason: nil,
      description: "Lists widgets",
      function_name: :list_widgets,
      name: "listWidgets",
      param_types: %{},
      required_params: []
    }
    assert is_tuple(Helpers.generate_one_arity_query(function, :adapter))
  end

  test "generate_two_arity_query/2 returns a tuple with an AST for a passed function" do
    function = %{
      deprecated: false,
      deprecated_reason: nil,
      description: "Lists widgets",
      function_name: :list_widgets,
      name: "listWidgets",
      param_types: %{},
      required_params: []
    }
    assert is_tuple(Helpers.generate_two_arity_query(function, :adapter))
  end

  test "get_param_types/1 returns a map of params with their GraphQL types" do
    data = [%{
      "defaultValue" => nil,
      "description" => nil,
      "name" => "id",
      "type" =>
        %{
          "kind" => "NON_NULL",
          "name" => nil,
          "ofType" => %{
            "kind" => "SCALAR",
            "name" => "ID",
            "ofType" => nil
          }
        }
    }]
    assert Helpers.get_param_types(data) == %{"id" => "ID"}
  end

  test "get_param_types/1 returns a map of params with their GraphQL types when there is a list" do
    data = [%{
      "defaultValue" => nil,
      "description" => nil,
      "name" => "id",
      "type" =>
        %{
          "kind" => "LIST",
          "name" => nil,
          "ofType" => %{
            "kind" => "INPUT_OBJECT",
            "name" => "RoleOrderByArgs",
            "ofType" => nil
          }
        }
    }]
    assert Helpers.get_param_types(data) == %{"id" => "[RoleOrderByArgs]"}
  end

  test "get_required_params/1 returns a list of keys for required params" do
    data = [%{
      "defaultValue" => nil,
      "description" => nil,
      "name" => "id",
      "type" =>
        %{
          "kind" => "NON_NULL",
          "name" => nil,
          "ofType" => %{
            "kind" => "SCALAR",
            "name" => "ID",
            "ofType" => nil
          }
        }
    }]
    assert Helpers.get_required_params(data) == [:id]
  end

end
