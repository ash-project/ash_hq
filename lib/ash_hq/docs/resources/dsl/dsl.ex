defmodule AshHq.Docs.Dsl do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :doc, :string do
      allow_nil? false
      constraints trim?: false, allow_empty?: true
      default ""
    end

    attribute :doc_html, :string do
      constraints trim?: false, allow_empty?: true
      writable? false
    end

    attribute :imports, {:array, :string} do
      default []
    end

    attribute :examples, {:array, :string}
    attribute :args, {:array, :string}
    attribute :optional_args, {:array, :string} do
      default []
    end
    attribute :arg_defaults, :map
    attribute :path, {:array, :string}
    attribute :recursive_as, :string
    attribute :order, :integer, allow_nil?: false

    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:entity, :section]
    end

    timestamps()
  end

  search do
    doc_attribute :doc

    load_for_search [
      :extension_order,
      :extension_type,
      :extension_name,
      :version_name,
      :library_name,
      :library_id
    ]

    sanitized_name_attribute :sanitized_path
    use_path_for_name? true
  end

  render_markdown do
    render_attributes doc: :doc_html
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end

    belongs_to :extension, AshHq.Docs.Extension do
      allow_nil? true
    end

    belongs_to :dsl, __MODULE__
    has_many :options, AshHq.Docs.Option
    has_many :dsls, __MODULE__
  end

  postgres do
    table "dsls"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
    end

    migration_defaults optional_args: "[]"
  end

  actions do
    defaults [:destroy]

    read :read do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25, required?: false
    end

    create :create do
      primary? true
      argument :options, {:array, :map}
      argument :library_version, :uuid

      argument :extension_id, :uuid do
        allow_nil? false
      end

      change {AshHq.Docs.Changes.AddArgToRelationship, arg: :extension_id, rel: :options}

      change {AshHq.Docs.Changes.AddArgToRelationship, arg: :library_version, rel: :options}
      change manage_relationship(:options, type: :direct_control)
      change manage_relationship(:library_version, type: :append_and_remove)
    end
  end

  code_interface do
    define_for AshHq.Docs
    define :read
  end

  resource do
    description "An entity or section in an Ash DSL"
  end

  aggregates do
    first :extension_type, :extension, :type
    first :extension_order, :extension, :order
    first :extension_name, :extension, :name
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
    first :library_id, [:library_version, :library], :id
  end
end
