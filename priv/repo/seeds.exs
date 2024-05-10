AshHq.Docs.Library.create!(
  %{
    name: "ash",
    display_name: "Ash",
    order: 0,
    module_prefixes: ["Ash"],
    description: """
    The core framework, providing all the features and goodies that power and enable the rest of the ecosystem.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_postgres",
    display_name: "AshPostgres",
    order: 10,
    module_prefixes: ["AshPostgres"],
    description: """
    A PostgreSQL data layer for Ash resources, allowing for rich query capabilities and seamless persistence.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_sqlite",
    display_name: "AshSqlite",
    order: 17,
    module_prefixes: ["AshSqlite"],
    description: """
    A Sqlite data layer for Ash resources. Supports fewer features than postgres, but is very lightweight and can be used as an in memory database."
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_phoenix",
    display_name: "AshPhoenix",
    module_prefixes: ["AshPhoenix"],
    order: 20,
    description: """
    Utilities for using Ash resources with Phoenix Framework, from building forms to running queries in sockets & LiveViews.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_graphql",
    display_name: "AshGraphql",
    module_prefixes: ["AshGraphql"],
    order: 40,
    description: """
    A GraphQL extension that allows you to build a rich and customizable GraphQL API with minimal configuration required.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_json_api",
    display_name: "AshJsonApi",
    module_prefixes: ["AshJsonApi"],
    order: 50,
    description: """
    A JSON:API extension that allows you to effortlessly create a JSON:API spec compliant API.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_authentication",
    display_name: "AshAuthentication",
    module_prefixes: ["AshAuthentication"],
    order: 55,
    repo_org: "team-alembic",
    description: """
    Provides drop-in support for user authentication with various strategies and tons of customizability.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_authentication_phoenix",
    display_name: "AshAuthenticationPhoenix",
    module_prefixes: ["AshAuthentication.Phoenix"],
    mix_project: "AshAuthentication.Phoenix.MixProject",
    order: 56,
    repo_org: "team-alembic",
    description: """
    Phoenix helpers and UI components in support of AshAuthentication.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_state_machine",
    display_name: "AshStateMachine",
    module_prefixes: ["AshStateMachine"],
    order: 62,
    description: """
    An Ash.Resource extension for building finite state machines.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_csv",
    display_name: "AshCSV",
    module_prefixes: ["AshCsv"],
    order: 70,
    description: """
    A CSV data layer allowing resources to be queried from and persisted in a CSV file.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_archival",
    display_name: "AshArchival",
    module_prefixes: ["AshArchival"],
    order: 85,
    description: """
    A light-weight resource extension that modifies resources to simulate deletion by setting an `archived_at` attribute.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_paper_trail",
    display_name: "AshPaperTrail",
    module_prefixes: ["AshPaperTrail"],
    order: 86,
    description: """
    Creates and manage a version tracking resource for a given resource.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_money",
    display_name: "AshMoney",
    module_prefixes: ["AshMoney"],
    order: 87,
    description: """
    A money extension that provides a money type and utilities for using it with various extensions.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_double_entry",
    display_name: "AshDoubleEntry",
    module_prefixes: ["AshDoubleEntry"],
    order: 89,
    description: """
    A customizable double entry bookkeeping system backed by Ash resources.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "reactor",
    display_name: "Reactor",
    module_prefixes: ["Reactor"],
    order: 91,
    description: """
    Reactor is a dynamic, concurrent, dependency resolving saga orchestrator.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_cloak",
    display_name: "AshCloak",
    module_prefixes: ["AshCloak"],
    order: 90,
    description: """
    An extension to seamlessly encrypt and decrypt resource attributes.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

# Always at the bottom
AshHq.Docs.Library.create!(
  %{
    name: "spark",
    display_name: "Spark",
    module_prefixes: ["Spark"],
    order: 100,
    description: """
    The core DSL and extension tooling, allowing for powerful, extensible DSLs with minimal effort.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)
