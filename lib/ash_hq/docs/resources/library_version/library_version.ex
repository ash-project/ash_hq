defmodule AshHq.Docs.LibraryVersion do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  render_markdown do
    render_attributes doc: :doc_html
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
    define :build, args: [:library, :version, :data]
    define :defined_for, args: [:library, :versions]
    define :by_version, args: [:version]
    define :destroy
    define :unprocessed
    define :process
  end

  actions do
    defaults [:read, :update, :destroy]

    read :by_version do
      get? true

      argument :version, :string do
        allow_nil? false
      end

      filter expr(version == ^arg(:version))
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

      change set_attribute(:id, {:arg, :id})

      change {AshHq.Docs.Changes.AddArgToRelationship,
              attr: :id, arg: :library_version, rel: :modules, generate: &Ash.UUID.generate/0}

      change manage_relationship(:guides, type: :direct_control)
      change manage_relationship(:library, type: :replace)
      change manage_relationship(:modules, type: :direct_control)
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

    read :unprocessed do
      filter expr(processed == false)
    end

    update :process do
      change AshHq.Docs.LibraryVersion.Changes.ProcessLibraryVersion
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

    attribute :data, :map

    attribute :doc, :string do
      allow_nil? false
      constraints trim?: false, allow_empty?: true
      default ""
    end

    attribute :doc_html, :string do
      constraints trim?: false, allow_empty?: true
      writable? false
    end

    attribute :processed, :boolean do
      default false
      writable? false
    end
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
      required? true
    end

    has_many :extensions, AshHq.Docs.Extension
    has_many :guides, AshHq.Docs.Guide
    has_many :modules, AshHq.Docs.Module
  end
end
