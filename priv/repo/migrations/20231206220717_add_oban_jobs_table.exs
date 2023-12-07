defmodule AshHq.Repo.Migrations.AddObanJobsTable do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 11)
  end

  def change do
    Oban.Migration.down(version: 1)
  end
end
