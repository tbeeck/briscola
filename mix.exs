defmodule Briscola.MixProject do
  use Mix.Project

  def project do
    [
      app: :briscola,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [
        ignore_modules: [
          Mix.Tasks.Briscola.Play,
          ~r"BriscolaTest.*",
          ~r"String\.Chars\.Briscola\..*"
        ]
      ],

      # Docs
      name: "Briscola",
      source_url: "https://github.com/tbeeck/briscola",
      docs: &docs/0
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Briscola",
      extras: ["README.md"]
    ]
  end
end
