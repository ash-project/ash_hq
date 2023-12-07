import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ash_hq, AshHq.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ash_hq_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

secret_key_base = "766JP3UO+dTbVfydE4RafFKbfUoudccDz1zS7x1N75WSiEJTq6dDR4r04+McH41m"

config :ash_hq, token_signing_secret: secret_key_base

config :ash_hq, Oban, testing: :inline

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ash_hq, AshHqWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: secret_key_base,
  server: false

config :ash_hq, AshHq.SqliteRepo,
  database: Path.join(__DIR__, "../ash-hq#{System.get_env("MIX_TEST_PARTITION")}.db"),
  pool_size: 10

config :ash_hq, cloak_key: "J6ED3yBWjlaOW/5byrukZTEryKa++yXWblJuhP91Qq8="

# In test we don't send emails.
config :ash_hq, AshHq.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :ash_hq, AshHq.Mailer, adapter: Swoosh.Adapters.Test

# config :plug_content_security_policy,
#   report_only: true
