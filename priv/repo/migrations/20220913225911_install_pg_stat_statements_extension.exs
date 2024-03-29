defmodule AshHq.Repo.Migrations.InstallPgStatStatements do
  @moduledoc """
  Installs any extensions that are mentioned in the repo's `installed_extensions/0` callback

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    # had to uncomment because fly.io doesn't allow
    # execute("CREATE EXTENSION IF NOT EXISTS \"pg_stat_statements\"")
  end

  def down do
    # execute("DROP EXTENSION IF EXISTS \"pg_stat_statements\"")
  end
end
