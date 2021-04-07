defmodule RelaxDot.MixProject do
  use Mix.Project

  def project do
    [
      app: :relax_dot,
      version: "0.1.0",
      elixir: "~> 1.7",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        relax_dot: [
          include_executables_for: [:unix, :windows],
          applications: [relax_dot: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {RelaxDot, []},
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
    ]
  end
end
