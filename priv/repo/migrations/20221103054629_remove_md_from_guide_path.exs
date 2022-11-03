defmodule AshHq.Repo.Migrations.RemoveMdFromGuidePath do
  use Ecto.Migration

  import Ecto.Query

  def up do
    query =
      from row in "guides",
        update: [set: [route: fragment("replace(?, '.md', '')", row.route)]]

    AshHq.Repo.update_all(query, [])
  end

  def down do
    raise "Can't revert this migration!"
  end
end
