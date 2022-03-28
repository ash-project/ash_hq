defmodule AshHq.Docs.Extension do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "extensions"
    repo AshHq.Repo
  end

  identities do
    identity :unique_name_by_library_version, [:name, :library_version_id]
  end

  code_interface do
    define_for AshHq.Docs

    define :import, args: [:library_version]
    define :destroy
  end

  actions do
    create :import do
      argument :library_version, :uuid do
        allow_nil? false
      end

      argument :dsls, {:array, :map}
      change manage_relationship(:library_version, type: :replace)
      change {AshHq.Docs.Changes.AddArgToRelationship, arg: :library_version, rel: :dsls}

      change {AshHq.Docs.Changes.AddArgToRelationship,
              attr: :id, arg: :extension_id, rel: :dsls, generate: &Ash.UUID.generate/0}

      change manage_relationship(:dsls, type: :direct_control)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :target, :string

    attribute :default_for_target, :boolean do
      default false
    end

    attribute :doc, :string do
      allow_nil? false
    end

    attribute :type, :string do
      allow_nil? false
    end

    attribute :order, :integer do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end

    has_many :dsls, AshHq.Docs.Dsl
    has_many :options, AshHq.Docs.Option
  end
end
