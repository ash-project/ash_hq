defmodule AshHq.Repo.Migrations.AddTsvectorIndices do
  use Ecto.Migration

  @config %{
    guides: {:name, :text},
    library_versions: {:version, :doc},
    options: {:name, :doc},
    dsls: {:name, :doc},
    extensions: {:name, :doc},
    functions: {:name, :doc},
    modules: {:name, :doc}
  }

  def change do
    for {table, {header, text}} <- @config do
      execute(
        """
        CREATE INDEX #{table}_search_index ON #{table} USING GIN((
          setweight(to_tsvector('english', #{header}), 'A') ||
          setweight(to_tsvector('english', #{text}), 'D')
        ));
        """,
        """
        DROP INDEX #{table}_search_index
        """
      )
    end
  end
end
