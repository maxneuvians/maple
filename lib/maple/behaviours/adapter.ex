defmodule Maple.Behaviours.Adapter do
  @moduledoc """
  Defines behaviour for an adapter to query a GraphQL server
  """

  @callback mutate(any, any) :: any
  @callback query(any, any) :: any
  @callback schema() :: map()

end
