defmodule AshHq.Repo.Migrations.MigrateResources59 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      remove(:ashley_access)
    end
  end

  def down do
    alter table(:users) do
      add(:ashley_access, :boolean, default: false)
    end
  end
end