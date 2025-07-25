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
    name: "igniter",
    display_name: "igniter",
    module_prefixes: ["Igniter"],
    order: 1,
    description: """
    A code generation and project patching framework.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_ai",
    display_name: "AshAI",
    module_prefixes: ["AshAI"],
    order: 2,
    description: """
    AI utilities and integrations for Ash Framework.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "usage_rules",
    display_name: "Usage Rules",
    module_prefixes: ["UsageRules"],
    order: 3,
    description: """
    Usage rules and guidelines for Ash Framework.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_ops",
    display_name: "AshOps",
    module_prefixes: ["AshOps"],
    order: 4,
    description: """
    Operations and deployment utilities for Ash applications.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "splode",
    display_name: "Splode",
    module_prefixes: ["Splode"],
    order: 5,
    description: """
    Error handling and exception utilities.
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
    name: "ash_sql",
    display_name: "AshSQL",
    order: 15,
    module_prefixes: ["AshSql"],
    description: """
    SQL utilities and shared functionality for SQL-based data layers.
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
    name: "ash_admin",
    display_name: "AshAdmin",
    module_prefixes: ["AshAdmin"],
    order: 25,
    description: """
    A rich admin interface for Ash resources with minimal configuration.
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
    name: "ash_oban",
    display_name: "AshOban",
    module_prefixes: ["AshOban"],
    order: 63,
    description: """
    Integration between Ash and Oban for background job processing.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_rate_limiter",
    display_name: "AshRateLimiter",
    module_prefixes: ["AshRateLimiter"],
    order: 64,
    description: """
    Rate limiting capabilities for Ash actions and resources.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_slug",
    display_name: "AshSlug",
    module_prefixes: ["AshSlug"],
    order: 65,
    description: """
    URL-friendly slug generation for Ash resources.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_events",
    display_name: "AshEvents",
    module_prefixes: ["AshEvents"],
    order: 66,
    description: """
    Event sourcing and event handling capabilities for Ash.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "ash_appsignal",
    display_name: "AshAppsignal",
    module_prefixes: ["AshAppsignal"],
    order: 67,
    description: """
    AppSignal integration for monitoring Ash applications.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "opentelemetry_ash",
    display_name: "OpenTelemetryAsh",
    module_prefixes: ["OpenTelemetryAsh"],
    order: 68,
    description: """
    OpenTelemetry integration for observability in Ash applications.
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
    name: "reactor_req",
    display_name: "ReactorReq",
    module_prefixes: ["ReactorReq"],
    order: 92,
    description: """
    HTTP request steps for Reactor workflows.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "reactor_file",
    display_name: "ReactorFile",
    module_prefixes: ["ReactorFile"],
    order: 93,
    description: """
    File system operations for Reactor workflows.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "reactor_process",
    display_name: "ReactorProcess",
    module_prefixes: ["ReactorProcess"],
    order: 94,
    description: """
    Process management steps for Reactor workflows.
    """
  },
  upsert?: true,
  upsert_identity: :unique_name
)

AshHq.Docs.Library.create!(
  %{
    name: "iterex",
    display_name: "Iterex",
    module_prefixes: ["Iterex"],
    order: 95,
    description: """
    Extended iteration utilities and helpers.
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
