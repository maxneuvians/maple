defmodule Maple.Mixfile do
  use Mix.Project

  def project do
    [app: :maple,
     version: "0.1.2",
     source_url: "https://github.com/maxneuvians/maple",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env),
     docs: [
      main: "readme",
      extras: ["README.md"]
     ]
   ]
  end

  defp elixirc_paths(:test), do: ["lib", "priv/maple", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/maple"]

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:poison, "~> 3.1"},
      {:tesla, "~> 0.8.0"}
    ]
  end

  defp description do
    """
    Maple is an automatic, compile time, client code generator for GraphQL schemas. At best it creates easy to use
    API functions for use in your code. At worst it can be used as a CLI for a GraphQL API.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Max Neuvians"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/maxneuvians/maple"}
    ]
  end
end
