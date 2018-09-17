defmodule DomainTools.MixProject do
  use Mix.Project

  def project do
    [
      app: :domain_tools,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {DomainTools.Application, []},
      extra_applications: [:logger, :idna]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:idna, ">= 6.0.0"}
    ]
  end
end
