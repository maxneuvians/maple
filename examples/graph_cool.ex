defmodule Maple.Examples.GraphCool.Config do
  Application.put_env(:maple, :api_url, "https://api.graph.cool/simple/v1/cj8gadz2802zi0131wp21ebk0")
  Application.put_env(:maple, :wss_url, "wss://subscriptions.graph.cool/v1/cj8gadz2802zi0131wp21ebk0")
end

defmodule Maple.Examples.GraphCool do
  use Maple

  def result(data), do: IO.inspect data
end
