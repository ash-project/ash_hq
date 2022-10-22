defmodule AshHq.Docs.Option do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  resource do
    description "Represents an option on a DSL section or entity"
  end

  render_markdown do
    render_attributes doc: :doc_html
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
    add_name_to_path? false
    show_docs_on :dsl_sanitized_path
  end

  postgres do
    table "options"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
    end
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

    attribute :doc, :string do
      allow_nil? false
      constraints trim?: false, allow_empty?: true
      default ""
    end

    attribute :doc_html, :string do
      constraints trim?: false, allow_empty?: true
      writable? false
    end

    attribute :required, :boolean do
      allow_nil? false
      default false
    end

    attribute :argument_index, :integer

    attribute :links, :map do
      default %{}
    end

    attribute :default, :string
    attribute :path, {:array, :string}
    attribute :order, :integer, allow_nil?: false
  end

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25, required?: false
    end

    create :create do
      primary? true
      argument :library_version, :uuid

      argument :extension_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:extension_id, :extension, type: :append_and_remove)
      change manage_relationship(:library_version, type: :append_and_remove)
    end
  end

  aggregates do
    first :extension_type, [:dsl, :extension], :type
    first :extension_name, [:dsl, :extension], :name
    first :extension_order, [:dsl, :extension], :order
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
    first :library_id, [:library_version, :library], :id
    first :dsl_sanitized_path, :dsl, :sanitized_path
  end

  relationships do
    belongs_to :dsl, AshHq.Docs.Dsl do
      allow_nil? true
    end

    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end

    belongs_to :extension, AshHq.Docs.Extension do
      allow_nil? true
    end
  end
end
