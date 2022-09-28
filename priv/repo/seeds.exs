AshHq.Docs.Library.create!(%{
  name: "ash",
  display_name: "Ash",
  order: 0,
  description: """
  The core framework, providing all the features and goodies that power and enable the rest of the ecosystem.
  """
})

AshHq.Docs.Library.create!(%{
  name: "ash_postgres",
  display_name: "AshPostgres",
  order: 10,
  description: """
  A PostgreSQL data layer for Ash resources, allowing for rich query capabilities and seamless persistence.
  """
})

AshHq.Docs.Library.create!(%{
  name: "ash_phoenix",
  display_name: "AshPhoenix",
  order: 20,
  description: """
  Utilities for using Ash resources with Phoenix Framework, from building forms to running queries in sockets & LiveViews.
  """
})

AshHq.Docs.Library.create!(%{
  name: "ash_graphql",
  display_name: "AshGraphql",
  order: 40,
  description: """
  A GraphQL extension that allows you to build a rich and customizable GraphQL API with minimal configuration required.
  """
})

AshHq.Docs.Library.create!(%{
  name: "ash_json_api",
  display_name: "AshJsonApi",
  order: 50,
  description: """
  A JSON:API extension that allows you to effortlessly create a JSON:API spec compliant API.
  """
})

AshHq.Docs.Library.create!(%{
  name: "ash_csv",
  display_name: "AshCSV",
  order: 70,
  description: """
  A CSV data layer allowing resources to be queried from and persisted in a CSV file.
  """
})

AshHq.Docs.Library.create!(%{
  name: "ash_archival",
  display_name: "AshArchival",
  order: 85,
  description: """
  A light-weight resource extension that modifies resources to simulate deletion by setting an `archived_at` attribute.
  """
})

# Always at the bottom
AshHq.Docs.Library.create!(%{
  name: "spark",
  display_name: "Spark",
  order: 100,
  description: """
  The core DSL and extension tooling, allowing for powerful, extensible DSLs with minimal effort.
  """
})
