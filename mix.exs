defmodule Orsimer.MixProject do
  use Mix.Project

  def project do
    [
      app: :orsimer,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:protobuf, "~> 0.7.1"},
      {:varint, "~> 1.3"},
      {:placebo, "~> 2.0.0-rc.2", only: [:dev, :test]},
      {:checkov, "~> 1.0", only: [:dev, :test]},
      {:divo, "~> 1.1", only: [:dev, :test]},
      {:prestige, "~> 1.1", only: [:dev, :test]},
      {:ex_aws_s3, "~> 2.0", only: [:dev, :test]},
      {:sweet_xml, "~> 0.6.6", only: [:dev, :test]},
      {:faker, "~> 0.13.0", only: [:dev, :test]}
    ]
  end
end
