defmodule AshHq.Repo.Migrations.AddTsvectorIndices do
  use Ecto.Migration

  @config %{
    guides: {:name, :text},
    library_versions: {:version, :doc},
    options: {:name, :doc},
    dsls: {:name, :doc},
    extensions: {:name, :doc}
  }

  def change do
    for {table, {header, text}} <- @config do
      execute """
      CREATE INDEX #{table}_search_index ON #{table} USING GIN((
        setweight(to_tsvector('simple', #{header}), 'A') ||
        setweight(to_tsvector('simple', #{text}), 'D')
      ));
      """,
      """
      DROP INDEX #{table}_search_index
      """
    end
  end
end
