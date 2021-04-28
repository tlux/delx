defmodule Delx.MixProject do
  use Mix.Project

  def project do
    [
      app: :delx,
      version: "3.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ],
      dialyzer: [plt_add_apps: [:ex_unit, :mix]],
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Delx",
      source_url: "https://github.com/tlux/delx",
      docs: [
        main: "Delx",
        extras: ["README.md"],
        groups_for_modules: [
          Delegators: [
            Delx.Delegator,
            Delx.Delegator.Common,
            Delx.Delegator.Mock
          ]
        ]
      ]
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
      {:benchee, "~> 1.0", only: :dev},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.24", only: :dev}
    ]
  end

  defp description do
    "An Elixir library to make function delegation testable."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tlux/delx"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
