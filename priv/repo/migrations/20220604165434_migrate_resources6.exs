defmodule AshHq.Repo.Migrations.MigrateResources6 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:library_versions) do
      remove(:processed)
      remove(:data)
    end

    alter table(:libraries) do
      remove(:description)

      modify(:track_branches, {:array, :text}, default: nil)
    end

    alter table(:functions) do
      modify(:heads, {:array, :text}, default: nil)
    end
  end

  def down do
    alter table(:functions) do
      modify(:heads, {:array, :text}, default: [])
    end

    alter table(:libraries) do
      modify(:track_branches, {:array, :text}, default: [])
      add(:description, :text)
    end

    alter table(:library_versions) do
      add(:data, :map)
      add(:processed, :boolean, default: false)
    end
  end
end
