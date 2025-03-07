# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ash_hq,
  ecto_repos: [AshHq.Repo]

config :ash, allow_flow: true

config :ash, :tracer, [AshAppsignal]

config :ash_appsignal,
  trace_types: [
    :custom,
    :action,
    :flow
  ]

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

{revision, _exitcode} = System.cmd("git", ["log", "--pretty=format:%h", "-n 1"])
config :appsignal, :config, revision: "test-4"

config :ash_hq,
  ash_domains: [
    AshHq.Accounts,
    AshHq.Blog,
    AshHq.Docs,
    AshHq.Github,
    AshHq.MailingList,
    AshHq.Discord
  ]

config :ash_hq, AshHq.Repo,
  timeout: :timer.minutes(10),
  ownership_timeout: :timer.minutes(10)

config :spark, :formatter,
  remove_parens?: true,
  "Ash.Resource": [
    type: Ash.Resource,
    section_order: [
      :actions,
      :authentication,
      :oban,
      :token,
      :attributes,
      :relationships,
      :policies,
      :postgres
    ]
  ],
  "Ash.Flow": []

# Configures the endpoint
config :ash_hq, AshHqWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [view: AshHqWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AshHq.PubSub,
  live_view: [signing_salt: "U1/3L4jI"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :ash_hq, AshHq.Mailer, adapter: Swoosh.Adapters.Local
config :ash_hq, AshHq.MailingList.Mailer, adapter: Swoosh.Adapters.Local
config :ash_hq, AshHqWeb.Tails, colors_file: Path.join(File.cwd!(), "assets/tailwind.colors.json")

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :plug_content_security_policy,
  nonces_for: [:script_src],
  directives: %{
    img_src: ~w('self' data:image/svg+xml),
    default_src: ~w('none'),
    connect_src: ~w('self'),
    child_src: ~w('self'),
    script_src: ~w('self'),
    style_src: ~w('self'),
    frame_src: ~w('self'),
    worker_src: ~w('self')
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
