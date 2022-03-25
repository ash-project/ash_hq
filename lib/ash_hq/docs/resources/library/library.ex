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
    define :create
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :track_branches, {:array, :string} do
      default []
    end
  end

  aggregates do
    first :latest_version, :versions, :version do
      sort version: :desc
      filter expr(version != "master")
    end
  end

  relationships do
    has_many :versions, AshHq.Docs.LibraryVersion
  end
end
