defmodule CDS.Config do
  Application.put_env(:maple, :api_url, "http://35.244.182.65/api")
  Application.put_env(:maple, :build_type_structs, true)
end

defmodule CDS do
  use Maple
end
