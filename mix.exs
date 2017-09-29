defmodule Maple.Mixfile do
  use Mix.Project

  def project do
    [app: :maple,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)
   ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv/maple", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/maple"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpotion, "~> 3.0.2"},
      {:poison, "~> 3.1"}
    ]
  end
end
