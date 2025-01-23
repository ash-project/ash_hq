defmodule AshHq.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ash_hq,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore_warnings",
        plt_add_apps: [:mix, :nostrum]
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
      {:timex, "~> 3.0"},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:ash, "~> 3.3"},
      {:ash_postgres, "~> 2.2"},
      {:ash_admin, "~> 0.11"},
      {:ash_phoenix, "~> 2.1"},
      {:ash_graphql, "~> 1.3"},
      {:ash_json_api, "~> 1.4"},
      {:ash_appsignal, "~> 0.1"},
      {:ash_blog, github: "ash-project/ash_blog"},
      {:ash_csv, "~> 0.9"},
      {:ash_oban, "~> 0.2"},
      {:earmark, "== 1.5.0-pre1"},
      {:picosat_elixir, "~> 0.2.3"},
      # Jobs
      {:oban, "~> 2.16"},
      {:flame, "~> 0.5.0"},
      # HTTP calls
      {:req, "~> 0.5.0"},
      # Appsignal
      {:appsignal_phoenix, "~> 2.0"},
      # Api Docs
      {:open_api_spex, "~> 3.16"},
      # Discord
      {:nostrum, github: "zachdaniel/nostrum"},
      # Search
      {:haystack, "~> 0.1.0"},
      # Clustering
      {:libcluster, "~> 3.3"},
      # UI
      {:tails, "~> 0.1"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      # Syntax Highlighting
      {:makeup, "~> 1.1"},
      {:makeup_elixir, "~> 1.0.0"},
      {:makeup_graphql, "~> 0.1.2"},
      {:makeup_erlang, "~> 1.0.0"},
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
      {:phoenix_html_helpers, "~> 1.0"},
      {:bandit, "~> 1.0"},
      {:phoenix, "~> 1.7"},
      {:phoenix_view, "~> 2.0"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:html_entities, "~> 0.5"},
      # locked for compatibility
      {:finch, "~> 0.10"},
      {:floki, "~> 0.30"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26 and >= 0.26.1"},
      {:jason, "~> 1.2"},
      # Build/Check dependencies
      {:git_ops, "~> 2.5", only: :dev},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:ex_check, "~> 0.14", only: :dev},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:eflame, "~> 1.0", only: [:dev, :test]},
      # Other
      {:absinthe_plug, "~> 1.5"}
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
        "seed"
      ],
      reset: ["ash.reset", "seed"],
      credo: "credo --strict",
      drop: ["ash_postgres.drop"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      sobelow: ["sobelow --skip -i Config.Headers,Config.CSRFRoute"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
