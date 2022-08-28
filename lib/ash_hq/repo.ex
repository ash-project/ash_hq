defmodule AshHq.Repo do
  use AshPostgres.Repo,
    otp_app: :ash_hq

  def installed_extensions do
    ["pg_trgm", "uuid-ossp", "citext", "pgstatstatements"]
  end
end
