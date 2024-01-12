defmodule AshHq.Docs.Library do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  actions do
    defaults [:create, :update, :destroy]

    read :read do
      primary? true

      argument :check_cache, :boolean do
        default true
      end

      prepare AshHq.Docs.Library.Preparations.CheckCache
    end

    read :by_name do
      argument :name, :string do
        allow_nil? false
      end

      filter expr(name == ^arg(:name))
    end

    read :pending_import do
      pagination keyset?: true, required?: false
      prepare AshHq.Docs.Library.Preparations.FilterPendingImport
    end

    update :import do
      transaction? false

      argument :metadata, :map do
        allow_nil? false

        constraints fields: [
                      version: [
                        type: :string,
                        allow_nil?: false
                      ]
                    ]
      end

      change fn changeset, _ ->
        Ash.Changeset.around_transaction(changeset, fn changeset, func ->
          FLAME.call(
            AshHq.ImporterPool,
            fn ->
              func.(changeset)
            end,
            timeout: :timer.minutes(10)
          )
        end)
      end

      manual AshHq.Docs.Library.Actions.Import
    end
  end

  oban do
    api AshHq.Docs

    triggers do
      trigger :import do
        queue :importer
        read_action :pending_import
        action :import
        scheduler_cron "0 */6 * * *"

        read_metadata fn record ->
          %{version: record.__metadata__.version}
        end
      end
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :display_name, :string do
      allow_nil? false
    end

    attribute :order, :integer do
      allow_nil? false
    end

    attribute :description, :string

    attribute :repo_org, :string do
      allow_nil? false
      default "ash-project"
    end

    attribute :module_prefixes, {:array, :string} do
      allow_nil? false
      default []
    end

    attribute :mix_project, :string

    attribute :skip_versions, {:array, :string} do
      default []
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :versions, AshHq.Docs.LibraryVersion

    has_one :latest_library_version, AshHq.Docs.LibraryVersion do
      sort version: :desc
      from_many? true
    end
  end

  postgres do
    table "libraries"
    repo AshHq.Repo

    migration_defaults module_prefixes: "[]", skip_versions: "[]"
  end

  code_interface do
    define_for AshHq.Docs

    define :read
    define :by_name, args: [:name], get?: true
    define :create
  end

  resource do
    description "Represents a library that will be imported into AshHq"
  end

  identities do
    identity :unique_order, [:order]
    identity :unique_name, [:name]
  end

  changes do
    change fn changeset, _ ->
      Ash.Changeset.after_action(changeset, fn _changeset, result ->
        AshHq.Docs.Library.Agent.clear()
        {:ok, result}
      end)
    end
  end

  calculations do
    calculate :latest_version, :string, expr(latest_library_version.version)
    calculate :latest_version_id, :uuid, expr(latest_library_version.id)
  end
end
