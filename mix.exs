defmodule DomainTools.MixProject do
  use Mix.Project

  def project do
    [
      app: :domain_tools,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: "https://github.com/norbu09/domain_tools"
    ]
  end

  defp package do
    [
      description: "Domain tools for Elixir",
      files: ["lib", "priv", "mix.exs", "README.md", ".formatter.exs"],
      maintainers: [
        "Lenz Gschwendtner"
      ],
      licenses: ["MIT"],
      links: %{github: "https://github.com/norbu09/domain_tools"}
    ]
  end

  def application do
    [
      mod: {DomainTools.Application, []},
      extra_applications: [:logger, :idna]
    ]
  end

  defp deps do
    [
      {:idna, ">= 6.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev} 
    ]
  end
end
