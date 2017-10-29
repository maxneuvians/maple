defmodule Maple.Clients.WebsocketApolloLegacy do
  @moduledoc """
  Implements an adapter to resolve the GraphQL subscriptions over a web socket connection.
  This adapter implements the `graphql-subscriptions` sub-protocol for Apollo servers.

  You could write your own adapter as long as it conforms to the
  `Maple.Behaviours.WebsocketAdapter` behaviour.
  """

  use WebSockex
  require Logger

  @behaviour Maple.Behaviours.WebsocketAdapter

  @gql_connection_init "init" # client -> server
  @gql_connection_ack "init_success" # server -> client
  @gql_connection_error "init_success_fail" # server -> client

  @gql_start "subscription_start" # client -> server
  @gql_success "subscription_success" # server -> client
  @gql_data "subscription_data" # server -> client
  @gql_error "subscription_fail" # server -> client
  @gql_stop "subscription_end" # client -> server

  @doc """
  Starts the websocket connection, registers the callback in the state,
  completes the initial handshacke and sends the subscription request.
  """
  @spec start_link(String.t, map(), function) :: atom()
  def start_link(query, params, callback) do
    id =
      UUID.uuid4
      |> String.to_atom

    WebSockex.start_link(
      Application.get_env(:maple, :wss_url),
      __MODULE__,
      %{
        id: id,
        callback: callback,
        params: params,
        query: query
      },
      extra_headers: headers(),
      name: id
    )
    send_init(id)
    start_subscription(%{id: id, params: params, query: query})
  end

  @doc """
  Callback after websocket connects
  """
  @spec handle_connect(%WebSockex.Conn{}, map()) :: {:ok, map()}
  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  @doc """
  Callback after incoming data
  """
  @spec handle_frame({:text, String.t}, map()) :: {:ok, map()}
  def handle_frame({:text, msg}, state) do
    decoded_msg = Poison.decode!(msg)
    case decoded_msg do
      %{"type" => @gql_connection_ack} ->
        Logger.info "Connection to websocket: #{Application.get_env(:maple, :wss_url)} successful"
      %{"type" => @gql_connection_error} ->
        Logger.info "Could not connect to websocket: #{Application.get_env(:maple, :wss_url)}"
      %{"type" => @gql_data, "id" => id, "payload" => payload} ->
        Logger.info "Received subscription data"
        if Atom.to_string(state.id) == id, do: apply(state.callback, [payload])
      %{"type" => @gql_success} ->
        Logger.info "Successful subscription"
      %{"type" => @gql_error} ->
        Logger.info "There was a subscription error: #{msg}"
      %{"type" => @gql_stop} ->
        Logger.info "Subscription ended"
      _ ->
        true
    end
    {:ok, state}
  end

  @spec send_msg(atom(), map()) :: :ok
  def send_msg(id, msg), do: WebSockex.send_frame(id, {:text, Poison.encode!(msg)})

  @spec headers() :: list()
  defp headers() do
    if Application.get_env(:maple, :additional_headers) do
      [{"Sec-WebSocket-Protocol", "graphql-ws"}, {"User-Agent", "Maple GraphQL Client"}]
        ++ Enum.map(Application.get_env(:maple, :additional_headers), fn k, v -> {k, v} end)
    else
      [{"Sec-WebSocket-Protocol", "graphql-subscriptions"}, {"User-Agent", "Maple GraphQL Client"}]
    end
  end

  @spec send_init(atom()) :: any()
  defp send_init(id), do: send_msg(id, %{type: @gql_connection_init})

  @spec start_subscription(map()) :: :ok
  defp start_subscription(state) do
     msg = %{
       type: @gql_start,
       query: state.query,
       variables: state.params,
       id: state.id
     }
     send_msg(state.id, msg)
  end
end
