defmodule AshHq.Repo.Migrations.MigrateResources2 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:modules) do
      remove(:extension_id)
    end

    alter table(:functions) do
      remove(:extension_id)
    end
  end

  def down do
    alter table(:functions) do
      add(
        :extension_id,
        references(:extensions, column: :id, name: "functions_extension_id_fkey", type: :uuid),
        null: false
      )
    end

    alter table(:modules) do
      add(
        :extension_id,
        references(:extensions, column: :id, name: "modules_extension_id_fkey", type: :uuid),
        null: false
      )
    end
  end
end
