defmodule AshHq.Docs.Option do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  postgres do
    table "options"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
      reference :dsl, on_delete: :delete
    end
  end

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true

      pagination offset?: true,
                 keyset?: true,
                 countable: true,
                 default_limit: 25,
                 required?: false
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

  search do
    doc_attribute :doc

    load_for_search [
      :extension_module,
      :library_name
    ]

    sanitized_name_attribute :sanitized_path
    use_path_for_name? true
    add_name_to_path? false
    show_docs_on :dsl_sanitized_path
  end

  render_markdown do
    render_attributes doc: :doc_html
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

    timestamps()
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

  code_interface do
    define_for AshHq.Docs
    define :read
  end

  resource do
    description "Represents an option on a DSL section or entity"
  end

  calculations do
    calculate :extension_type, :string, expr(dsl.extension.type)
    calculate :extension_order, :integer, expr(dsl.extension.order)
    calculate :extension_module, :string, expr(dsl.extension.module)
    calculate :version_name, :string, expr(library_version.version)
    calculate :library_name, :string, expr(library_version.library.name)
    calculate :library_id, :string, expr(library_version.library.id)
    calculate :dsl_sanitized_path, :string, expr(dsl.sanitized_path)
  end
end
