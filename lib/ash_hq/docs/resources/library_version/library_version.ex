defmodule AshHq.Docs.LibraryVersion do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  postgres do
    table "library_versions"
    repo AshHq.Repo
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

  search do
    name_attribute :version
    load_for_search [:library_name, :library_display_name]
  end

  attributes do
    uuid_primary_key :id

    attribute :version, :string do
      allow_nil? false
    end

    attribute :hydrated, :boolean do
      default false
      allow_nil? false
    end

    timestamps()
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

  code_interface do
    define_for AshHq.Docs
    define :build, args: [:library, :version]
    define :defined_for, args: [:library, :versions]
    define :by_version, args: [:library, :version]
    define :destroy
  end

  resource do
    description "Represents a version of a library that has been imported."
  end

  identities do
    identity :unique_version_for_library, [:version, :library_id]
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
    calculate :library_name, :string, expr(library.name)
    calculate :library_display_name, :string, expr(library.display_name)
  end
end
