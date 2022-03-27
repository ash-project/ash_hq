defmodule AshHq.Docs.Library do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "libraries"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Docs

    define :read
    define :by_name, args: [:name], get?: true
    define :create
  end

  actions do
    read :read do
      primary? true
    end

    read :by_name do
      argument :name, :string do
        allow_nil? false
      end

      filter expr(name == ^arg(:name))
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

    attribute :track_branches, {:array, :string} do
      default []
    end
  end

  aggregates do
    first :latest_version, :versions, :version do
      sort version: :desc
      filter expr(contains(version, "."))
    end
  end

  relationships do
    has_many :versions, AshHq.Docs.LibraryVersion
  end
end
