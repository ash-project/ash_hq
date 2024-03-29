defmodule AshHq.Repo.Migrations.MigrateResources3 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_sqlite.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:extensions) do
      remove :doc_html
    end
  end

  def down do
    alter table(:extensions) do
      add :doc_html, :text
    end
  end
end
