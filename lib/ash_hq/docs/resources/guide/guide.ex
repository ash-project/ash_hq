defmodule AshHq.Docs.Guide do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    repo AshHq.Repo
    table "guides"
  end

  attributes do
    uuid_primary_key :id

    attribute :order, :integer do
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
    end

    attribute :text, :string do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end
  end
end
