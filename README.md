# Maple

Maple is an automatic, compile time, code generator for GraphQL schemas. At best it creates easy to use
API functions for use in your code. At worst it can be used as a CLI for a GraphQL API.

Best illustrated by an example - given the following code

```elixir
defmodule Maple.Examples.Github.Config do
  Application.put_env(:maple, :api_url, "https://api.github.com/graphql")
  Application.put_env(:maple, :token, "TOKEN")
end

defmodule Maple.Examples.Github do
  use Maple
  generate_graphql_functions()
end
```

`generate_graphql_functions` will create all the query and mutation functions for the GitHub GraphQL API.

So you can do the following:

```elixir
iex(1)> c "examples/github.ex", "." # We need to compile the BEAM file to access the documentation
[Maple.Examples.Github, Maple.Examples.Github.Config]

iex(2)> h Maple.Examples.Github.viewer/1

                               def viewer(fields)

The currently authenticated user.

iex(3)> Maple.Examples.Github.viewer("login")
%Maple.Response{body: %{"viewer" => %{"login" => "maxneuvians"}}, status: 200}

iex(4)> Maple.Examples.Github.user(%{login: "maxneuvians"}, "name")
%Maple.Response{body: %{"user" => %{"name" => "Max Neuvians"}}, status: 200}

iex(5)> Maple.Examples.Github.user(%{},"name")
{:error, "Query is missing the following required params: login"}
```

`query` functions can are either arity `/1` or `/2` depending if they have required params. `mutation` functions
are always arity `/2`. Arity `/2` functions always take a `map` as the first argument and a `string` as the second,
which match the GraphQL `params` and `query` string concept.

Function names are changed from camel to snake case. ex `listUsers` becomes `list_users`.

## Installation

```elixir
def deps do
  [{:maple, git: "https://github.com/maxneuvians/maple"}]
end
```

## Configuration

If you only access one end p

## Ramblings

This library is in development.

`Maple.generate_graphql_functions` can be passed an optional adapter to resolve the GraphQL interaction.

Compare `test/support/test_adapter.ex` and `lib/maple/client.ex` to see an example. This will allow you to build clients based
on local JSON schema files. ex. `test\data\schema.json`

The library can also create structs based on GraphQL types (currently commented out). The idea was to parse the result data
through the struct for validation

## License
MIT

## Version
0.1.0
