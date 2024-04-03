defmodule AshHq.Docs.Function do
  @moduledoc false

  use Ash.Resource,
    domain: AshHq.Docs,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  actions do
    default_accept :*
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

      change manage_relationship(:library_version, type: :append_and_remove)
    end
  end

  search do
    doc_attribute :doc

    load_for_search [
      :version_name,
      :library_name,
      :module_name,
      :call_name,
      :library_id
    ]

    type "Code"

    show_docs_on :module_sanitized_name
  end

  render_markdown do
    render_attributes doc: :doc_html, heads: :heads_html
    header_ids? false
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :file, :string do
      public? true
    end
    attribute :line, :integer do
      public? true
    end

    attribute :arity, :integer do
      public? true
      allow_nil? false
    end

    attribute :type, :atom do
      public? true
      constraints one_of: [:function, :macro, :callback, :type]
      allow_nil? false
    end

    attribute :heads, {:array, :string} do
      public? true
      default []
    end

    attribute :heads_html, {:array, :string} do
      public? true
      default []
    end

    attribute :doc, :string do
      public? true
      allow_nil? false
      constraints trim?: false, allow_empty?: true
      default ""
    end

    attribute :doc_html, :string do
      public? true
      constraints trim?: false, allow_empty?: true
      writable? false
    end

    attribute :order, :integer do
      public? true
      allow_nil? false
    end

    attribute :deprecated, :string do
      public? true
      allow_nil? true
    end

    timestamps()
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      public? true
      allow_nil? true
    end

    belongs_to :module, AshHq.Docs.Module do
      public? true
      allow_nil? true
    end
  end

  postgres do
    table "functions"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
    end
  end


  resource do
    description "A function in a module exposed by an Ash library"
  end

  calculations do
    calculate :version_name, :string, expr(library_version.version)
    calculate :library_name, :string, expr(library_version.library.name)
    calculate :library_id, :uuid, expr(library_version.library.id)
    calculate :module_name, :string, expr(module.name)
    calculate :module_sanitized_name, :string, expr(module.sanitized_name)
    calculate :call_name, :string, expr(module_name <> "." <> name)
  end
end
