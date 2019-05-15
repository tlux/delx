defmodule Delx.MixProject do
  use Mix.Project

  def project do
    [
      app: :delx,
      version: "1.0.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Delx",
      source_url: "https://github.com/i22-digitalagentur/delx",
      docs: [
        main: "Delx",
        extras: ["README.md"],
        groups_for_modules: [
          Delegators: [
            Delx.Delegator,
            Delx.Delegator.Common,
            Delx.Delegator.Stub
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
      {:excoveralls, "~> 0.11.0", only: :test},
      {:ex_doc, "~> 0.20.2", only: :dev}
    ]
  end

  defp description do
    "An Elixir library to make function delegation testable."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Source" => "https://github.com/i22-digitalagentur/delx"
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
