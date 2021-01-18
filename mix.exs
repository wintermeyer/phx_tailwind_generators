defmodule PhxTailwindGenerators.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_tailwind_generators,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Generators to create templates with Tailwind CSS.",
      name: "PhxTailwindGenerators",
      source_url: "https://github.com/wintermeyer/phx_tailwind_generators"
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
      {:phoenix, "~> 1.5.7"}
    ]
  end
end
