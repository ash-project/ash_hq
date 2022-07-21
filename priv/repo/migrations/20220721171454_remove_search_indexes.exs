defmodule AshHq.Repo.Migrations.RemoveSearchIndexes do
  use Ecto.Migration

  @tables [
    :guides,
    :library_versions,
    :options,
    :dsls,
    :extensions,
    :functions,
    :modules
  ]

  def change do
    for table <- @tables do
      execute("DROP INDEX IF EXISTS #{table}_search_index")
    end
  end
end
