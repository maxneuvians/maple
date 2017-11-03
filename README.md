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

## Subscriptions

It appears that at this point in time the support of subscriptions over web sockets are a work in progress.

For example, [https://github.com/apollographql/subscriptions-transport-ws/](https://github.com/apollographql/subscriptions-transport-ws/)
implements a legacy (`graphql-subscriptions`) and a current (`graphql-ws`) web socket subprotocol for Apollo servers. For more information please take a look here: [https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md](https://github.com/apollographql/subscriptions-transport-ws/blob/master/PROTOCOL.md)

Maple currently supports both protocols, although you will need to specify the legacy adapter if you are using `graphql-subscriptions`. Ex.
```
generate_graphql_functions(websocket_adapter: :"Elixir.Maple.Clients.WebsocketApolloLegacy")
```

Once Absinthe 1.4 has been released I will implement it as an adapter. Here is an example interaction with a Scaphold.io API:

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
status
```

## Options

The module takes a options from the configuration:

```
config :maple,
  build_type_structs: false,
  http_adapter: Maple.Clients.Http,
  websocket_adapter: Maple.Clients.WebsocketApollo
```

- `:build_type_structs` - Default is `false`. If set to `true` the macro will create
structs for all the fields found in the introspection query. All types are namespaced into
`Maple.Types.`

- `:http_adapter` - The default HTTP adapter for completing transactions against the GraphQL
server. Default is: `Maple.Clients.Http`

- `:websocket_adapter` - The default Websocket adapter for completing transactions against the GraphQL
server using websockets. Default is: `Maple.Clients.WebsocketApollo`

## Installation

```elixir
def deps do
  [{:maple, git: "https://github.com/maxneuvians/maple"}]
end
```

or

```elixir
def deps do
  [{:maple, "~> 0.3.0"}]
end
```

## Configuration

If you only access one GraphQL API you just need to add the following to you config.exs

```
config :maple,
  api_url: "URL",
  wss_url:, "WSS_URL", # If you are using subscriptions over websockets.
  additional_headers: %{"Authorization": "Bearer TOKEN"} # If you have any additional headers
```

## Ramblings

This library is in development.

Contributions and issues welcome!

__Also if you think this is a terrible idea, please let me know!__

## ToDo

- [X] Refactor macro code
- [X] Add proper documentation
- [X] Support subscriptions
- [ ] Support fragments
- [ ] Look into validation through structs
- [X] Expand help with required attributes
- [X] Expand help with attribute descriptions

## License
MIT

## Version
0.2.0
