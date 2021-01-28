defmodule PhxTailwindGenerators.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_tailwind_generators,
      version: "0.1.6",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Generators to create templates with Tailwind CSS.",
      name: "PhxTailwindGenerators",
      package: %{
        maintainers: ["Stefan Wintermeyer"],
        licenses: ["MIT"],
        links: %{
          github: "https://github.com/wintermeyer/phx_tailwind_generators"
        },
      },
      source_url: "https://github.com/wintermeyer/phx_tailwind_generators",
      homepage_url: "https://github.com/wintermeyer/phx_tailwind_generators",
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
      {:phoenix, "~> 1.5.7"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
