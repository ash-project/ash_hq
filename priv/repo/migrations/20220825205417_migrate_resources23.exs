defmodule AshHq.Repo.Migrations.MigrateResources23 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:modules) do
      remove(:category_index)
    end
  end

  def down do
    alter table(:modules) do
      add(:category_index, :bigint, null: false, default: 0)
    end
  end
end
