defmodule AshHq.Docs.LibraryVersion do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "library_versions"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Docs
    define :build, args: [:library, :version, :data]
    define :defined_for, args: [:library, :versions]
    define :unprocessed
    define :process
  end

  actions do
    read :read do
      primary? true
    end

    create :build do
      argument :library, :uuid do
        allow_nil? false
      end

      change manage_relationship(:library, type: :replace)
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

  attributes do
    uuid_primary_key :id

    attribute :version, :string do
      allow_nil? false
    end

    attribute :data, :map

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
  end
end
