defmodule AshHq.Repo.Migrations.MigrateResources40 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:dsls) do
      add :optional_args, {:array, :text}, default: []
      add :arg_defaults, :map
    end
  end

  def down do
    alter table(:dsls) do
      remove :arg_defaults
      remove :optional_args
    end
  end
end