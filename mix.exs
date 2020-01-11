defmodule SlackWorkflow.MixProject do
  use Mix.Project

  def project do
    [
      app: :slack_workflow,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:timex, "~> 3.6"},
      {:csv, "~> 2.3"}
    ]
  end

  defp escript_config do
    [main_module: SlackWorkflow]
  end
end
