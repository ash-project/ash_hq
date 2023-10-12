defmodule AshHq.SqliteRepo do
  @moduledoc "Ecto repo for interacting with Sqlite"
  use AshSqlite.Repo,
    otp_app: :ash_hq
end
