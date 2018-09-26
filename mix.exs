defmodule Exnem.MixProject do
  use Mix.Project

  def project do
    [
      app: :exnem,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:keccakf1600, "~> 2.0"},
      {:kcl, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:websockex, "~> 0.4"},
      {:ecto, "~> 2.1"},
      {:faker, "~> 0.10.0"}
    ]
  end
end
