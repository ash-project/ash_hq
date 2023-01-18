defmodule AshHq.Docs.Library do
  @moduledoc false
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

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

    timestamps()
  end

  relationships do
    has_many :versions, AshHq.Docs.LibraryVersion
  end

  postgres do
    table "libraries"
    repo AshHq.Repo

    migration_defaults module_prefixes: "[]"
  end

  actions do
    defaults [:create, :update, :destroy]

    read :read do
      primary? true

      argument :check_cache, :boolean do
        default true
      end

      prepare fn query, _ ->
        if Ash.Query.get_argument(query, :check_cache) do
          Ash.Query.before_action(query, fn query ->
            AshHq.Docs
            |> Ash.Filter.Runtime.filter_matches(
              AshHq.Docs.Library.Agent.get(),
              query.filter
            )
            |> case do
              {:ok, results} ->
                Ash.Query.set_result(query, {:ok, Ash.Sort.runtime_sort(results, query.sort)})

              {:error, _} ->
                query
            end
          end)
        else
          query
        end
      end
    end

    read :by_name do
      argument :name, :string do
        allow_nil? false
      end

      filter expr(name == ^arg(:name))
    end
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

  aggregates do
    first :latest_version, :versions, :version do
      sort version: :desc
    end
  end
end
