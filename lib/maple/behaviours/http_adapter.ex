defmodule Maple.Behaviours.HttpAdapter do
  @moduledoc """
  Defines behaviour for a http adapter to query a GraphQL server
  """

  @callback mutate(any, any, any) :: any
  @callback query(any, any, any) :: any
  @callback schema() :: map()

end
