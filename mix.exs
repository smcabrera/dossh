defmodule Dossh.Mixfile do
  use Mix.Project

  def project do
    [app: :dossh,
     escript: escript_config,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [ applications: [:logger, :httpoison, :table_rex] ]
  end

  defp deps do
    [
      { :httpoison, "~> 0.9" },
      { :poison, "~> 2.2" },
      { :table_rex, "~> 0.8" },
    ]
  end

  defp escript_config do
    [ main_module: Dossh.CLI ]
  end
end
