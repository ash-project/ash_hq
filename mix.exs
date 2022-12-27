defmodule AshHq.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ash_hq,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:surface],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore_warnings",
        plt_add_apps: [:mix]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AshHq.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ash, github: "ash-project/ash", override: true},
      {:ash_postgres, "~> 1.1"},
      {:ash_admin, github: "ash-project/ash_admin"},
      {:ash_phoenix, github: "ash-project/ash_phoenix", override: true},
      {:ash_graphql, github: "ash-project/ash_graphql"},
      {:ash_json_api, github: "ash-project/ash_json_api"},
      {:absinthe_plug, "~> 1.5"},
      {:ash_blog, github: "ash-project/ash_blog"},
      {:ash_csv, github: "ash-project/ash_csv"},
      {:tails, "~> 0.1"},
      {:sunflower_ui, github: "zachdaniel/sunflower_ui"},
      {:earmark, "~> 1.5.0-pre1", override: true},
      {:nimble_options, "~> 0.5.1", override: true},
      {:spark, "~> 0.3", override: true},
      {:surface, "~> 0.9.1"},
      {:surface_heroicons, "~> 0.6.0"},
      {:ua_inspector, "~> 3.0"},
      # Syntax Highlighting
      {:makeup, "~> 1.1"},
      {:makeup_elixir, "~> 0.16.0"},
      {:makeup_graphql, "~> 0.1.2"},
      {:makeup_erlang, "~> 0.1.1"},
      {:makeup_eex, "~> 0.1.1"},
      {:makeup_js, "~> 0.1.0"},
      {:makeup_sql, "~> 0.1.0"},
      # Emails
      {:swoosh, "~> 1.3"},
      {:premailex, "~> 0.3.0"},
      # Authentication
      {:bcrypt_elixir, "~> 3.0"},
      # Encryption
      {:cloak, "~> 1.1"},
      # CSP
      {:plug_content_security_policy, "~> 0.2.1"},
      # Live Dashboard
      {:phoenix_live_dashboard, "~> 0.6"},
      {:ecto_psql_extras, "~> 0.6"},
      {:phoenix_ecto, "~> 4.4"},
      # Phoenix/Core dependencies
      {:phoenix, "~> 1.7.0-rc.0", override: true},
      {:phoenix_view, "~> 2.0"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18"},
      {:finch, "~> 0.10.2"},
      {:floki, ">= 0.30.0"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      # Build/Check dependencies
      {:git_ops, "~> 2.5", only: :dev},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:ex_check, "~> 0.14", only: :dev},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:eflame, "~> 1.0", only: [:dev, :test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      seed: ["run priv/repo/seeds.exs"],
      setup: [
        "ash_postgres.create",
        "ash_postgres.migrate",
        "seed",
        "ua_inspector.download --force"
      ],
      reset: ["drop", "setup"],
      credo: "credo --strict",
      drop: ["ash_postgres.drop"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      sobelow: ["sobelow --skip -i Config.Headers,Config.CSRFRoute"],
      "assets.deploy": [
        "cmd --cd assets npm install && npm run deploy",
        "esbuild default --minify",
        "phx.digest"
      ]
    ]
  end
end
