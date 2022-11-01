defmodule AshHq.Docs.LibraryVersion do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  resource do
    description "Represents a version of a library that has been imported."
  end

  search do
    name_attribute :version
    library_version_attribute :id
    load_for_search [:library_name, :library_display_name]
  end

  postgres do
    table "library_versions"
    repo AshHq.Repo
  end

  identities do
    identity :unique_version_for_library, [:version, :library_id]
  end

  code_interface do
    define_for AshHq.Docs
    define :build, args: [:library, :version]
    define :defined_for, args: [:library, :versions]
    define :by_version, args: [:library, :version]
    define :destroy
  end

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25, required?: false
    end

    read :by_version do
      get? true

      argument :version, :string do
        allow_nil? false
      end

      argument :library, :uuid do
        allow_nil? false
      end

      filter expr(version == ^arg(:version) and library == ^arg(:library))
    end

    create :build do
      argument :id, :uuid

      argument :library, :uuid do
        allow_nil? false
      end

      argument :guides, {:array, :map} do
        allow_nil? false
      end

      argument :modules, {:array, :map} do
        allow_nil? false
      end

      argument :mix_tasks, {:array, :map} do
        allow_nil? false
      end

      argument :extensions, {:array, :map} do
        allow_nil? false
      end

      change set_attribute(:id, arg(:id))

      change {AshHq.Docs.Changes.AddArgToRelationship,
              attr: :id, arg: :library_version, rel: :modules, generate: &Ash.UUID.generate/0}

      change {AshHq.Docs.Changes.AddArgToRelationship,
              attr: :id, arg: :library_version, rel: :mix_tasks, generate: &Ash.UUID.generate/0}

      change {AshHq.Docs.Changes.AddArgToRelationship,
              attr: :id, arg: :library_version, rel: :extensions, generate: &Ash.UUID.generate/0}

      # foo
      change manage_relationship(:guides, type: :create)
      change manage_relationship(:library, type: :append_and_remove)
      change manage_relationship(:modules, type: :create)
      change manage_relationship(:mix_tasks, type: :create)
      change manage_relationship(:extensions, type: :create)
    end

    read :defined_for do
      argument :library, :uuid do
        allow_nil? false
      end

      argument :versions, {:array, :string} do
        allow_nil? false
      end

      filter expr(version in ^arg(:versions) and library_id == ^arg(:library))
    end
  end

  aggregates do
    first :library_name, :library, :name
    first :library_display_name, :library, :display_name
  end

  attributes do
    uuid_primary_key :id

    attribute :version, :string do
      allow_nil? false
    end

    timestamps()
  end

  calculations do
    calculate :sortable_version,
              {:array, :string},
              expr(fragment("string_to_array(?, '.')", version))
  end

  preparations do
    prepare AshHq.Docs.LibraryVersion.Preparations.SortBySortableVersionInstead
  end

  relationships do
    belongs_to :library, AshHq.Docs.Library do
      allow_nil? true
    end

    has_many :extensions, AshHq.Docs.Extension
    has_many :guides, AshHq.Docs.Guide
    has_many :modules, AshHq.Docs.Module
    has_many :mix_tasks, AshHq.Docs.MixTask
  end
end
