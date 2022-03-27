defmodule AshHq.Docs.Option do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search]

  search do
    load_for_search([:extension_type, :extension_name, :version_name, :library_name])
  end

  postgres do
    table "options"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Docs
    define :read
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :type, :string do
      allow_nil? false
    end

    attribute :doc, :string

    attribute :required, :boolean do
      allow_nil? false
      default false
    end

    attribute :default, :string
    attribute :path, {:array, :string}
    attribute :order, :integer, allow_nil?: false
  end

  actions do
    read :read do
      primary? true
    end

    create :create do
      argument :library_version, :uuid

      argument :extension_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:extension_id, :extension, type: :replace)
      change manage_relationship(:library_version, type: :replace)
    end
  end

  aggregates do
    first :extension_type, [:dsl, :extension], :type
    first :extension_name, [:dsl, :extension], :name
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
  end

  relationships do
    belongs_to :dsl, AshHq.Docs.Dsl do
      required? true
    end

    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end

    belongs_to :extension, AshHq.Docs.Extension do
      required? true
    end
  end
end
