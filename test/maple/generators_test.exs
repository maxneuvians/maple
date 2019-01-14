defmodule MapleTest.Maple.GeneratorsTest do
  use ExUnit.Case

  alias Maple.Generators

  test "mutation/2 returns a tuple with an AST for a passed function" do
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
    assert is_tuple(Generators.mutation(function, :adapter))
  end

  test "query/2 returns a tuple with an AST for a passed function" do
    function = %{
      deprecated: false,
      deprecated_reason: nil,
      description: "Lists widgets",
      function_name: :list_widgets,
      name: "listWidgets",
      param_types: %{},
      required_params: []
    }
    assert is_tuple(Generators.query(function, :adapter))
  end

end
