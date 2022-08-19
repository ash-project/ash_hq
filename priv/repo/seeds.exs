# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AshHq.Repo.insert!(%AshHq.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

AshHq.Docs.Library.create!(%{name: "ash", display_name: "Ash"})
AshHq.Docs.Library.create!(%{name: "spark", display_name: "Spark"})

# AshHq.Docs.Library.create!(%{
#   name: "ash_archival",
#   display_name: "AshArchival"
# })

# AshHq.Docs.Library.create!(%{
#   name: "ash_postgres",
#   display_name: "AshPostgres"
# })
