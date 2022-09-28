defmodule AshHq.Docs.Library do
  @moduledoc false
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  resource do
    description "Represents a library that will be imported into AshHq"
  end

  identities do
    identity :unique_order, [:order]
    identity :unique_name, [:name]
  end

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
    defaults [:read, :create, :update, :destroy]

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

    attribute :order, :integer do
      allow_nil? false
    end

    attribute :description, :string
  end

  aggregates do
    first :latest_version, :versions, :version do
      sort version: :desc
    end
  end

  relationships do
    has_many :versions, AshHq.Docs.LibraryVersion
  end
end
