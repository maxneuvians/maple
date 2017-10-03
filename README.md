# Maple

[![Master](https://travis-ci.org/maxneuvians/maple.svg?branch=master)](https://travis-ci.org/maxneuvians/maple)


Maple is an automatic, compile time, client code generator for GraphQL schemas. At best it creates easy to use
API functions for use in your code. At worst it can be used as a CLI for a GraphQL API.

Best illustrated by an example - given the following code

```elixir
defmodule Maple.Examples.Github.Config do
  Application.put_env(:maple, :api_url, "https://api.github.com/graphql")
  Application.put_env(:maple, :additional_headers, %{"Authorization" => "Bearer TOKEN"})
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

iex(2)> h Maple.Examples.Github.user

                            def user(params, fields)

Lookup a user by login.

Param name: login

  • Description: The user's login.
  • Type: String
  • Required: Yes

iex(3)> Maple.Examples.Github.viewer("login")
%Maple.Response{body: %{"viewer" => %{"login" => "maxneuvians"}}, status: 200}

iex(4)> Maple.Examples.Github.user(%{login: "maxneuvians"}, "name")
%Maple.Response{body: %{"user" => %{"name" => "Max Neuvians"}}, status: 200}

iex(5)> Maple.Examples.Github.user(%{},"name")
{:error, "Query is missing the following required params: login"}
```

`query` functions can are either arity `/1` or `/2` depending if they have required params. `mutation` functions
are always arity `/2`. Arity `/2` functions always take a `map` as the first argument and a `string` as the second,
which match the GraphQL `params` and `fields` concept.

Function names are changed from camel to snake case. ex `listUsers` becomes `list_users`.

Take a look at `examples/` for more examples.

## Installation

```elixir
def deps do
  [{:maple, git: "https://github.com/maxneuvians/maple"}]
end
```

or

```elixir
def deps do
  [{:maple, "~> 0.1.0"}]
end
```

## Configuration

If you only access one GraphQL API you just need to add the following to you config.exs

```
config :maple,
  api_url: "URL",
  additional_headers: %{"Authorization": "Bearer TOKEN"} # If you have any additional headers
```

## Ramblings

This library is in development.

`Maple.generate_graphql_functions` can be passed an optional adapter to resolve the GraphQL interaction.

Compare `test/support/test_adapter.ex` and `lib/maple/client.ex` to see an example. This will allow you to build clients based
on local JSON schema files. ex. `test\data\schema.json`

The library can also create structs based on GraphQL types (currently commented out). The idea was to parse the result data
through the struct for validation.

Contributions and issues welcome!

__Also if you think this is a terrible idea, please let me know!__

## ToDo

- [X] Refactor macro code
- [X] Add proper documentation
- [ ] Support subscriptions
- [ ] Look into validation through structs
- [X] Expand help with required attributes
- [X] Expand help with attribute descriptions

## License
MIT

## Version
0.1.1
