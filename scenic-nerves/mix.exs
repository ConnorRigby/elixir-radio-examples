defmodule Radio.MixProject do
  use Mix.Project

  @app :radio
  @version "0.1.0"
  @all_targets [:rpi3a]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.6"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Radio.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.6", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.8"},
      {:toolshed, "~> 0.2"},
      {:scenic, "~> 0.10"},

      # Dependencies for only the :host
      {:scenic_driver_glfw, "~> 0.10", targets: :host},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11", targets: @all_targets},
      {:nerves_pack, "~> 0.3.0", targets: @all_targets},
      {:scenic_driver_nerves_rpi, "~> 0.10", targets: @all_targets},
      {:scenic_driver_nerves_touch, "~> 0.10", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi3a, "~> 1.11", runtime: false, targets: :rpi3a},
      {:rf69, path: "../../rf69"}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
