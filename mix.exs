defmodule Deadline.MixProject do
  use Mix.Project

  @version "0.7.1"

  def project do
    [
      app: :deadline,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Deadline",
      source_url: "https://github.com/keathley/deadline",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Deadline.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: [:dev, :test]}
    ]
  end

  def description do
    """
    Deadline is a small library for managing deadlines and deadline propagation.
    """
  end

  def package do
    [
      name: "deadline",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/keathley/deadline"}
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: "https://github.com/keathley/deadline",
      main: "Deadline"
    ]
  end
end
