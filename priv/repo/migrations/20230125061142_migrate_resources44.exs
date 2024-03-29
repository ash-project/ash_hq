defmodule AshHq.Repo.Migrations.MigrateResources44 do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    execute("""
    CREATE INDEX discord_messages_search_index ON discord_messages USING GIN((
      setweight(to_tsvector('english', content), 'D')
    ));
    """)
  end

  def down do
    execute("""
    DROP INDEX discord_messages_search_index;
    """)
  end
end
