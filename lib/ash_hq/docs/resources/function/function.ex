defmodule AshHq.Docs.Function do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  resource do
    description "A function in a module exposed by an Ash library"
  end

  render_markdown do
    render_attributes doc: :doc_html, heads: :heads_html
    header_ids? false
  end

  search do
    doc_attribute :doc

    load_for_search [
      :version_name,
      :library_name,
      :module_name,
      :library_id
    ]

    type "Code"

    show_docs_on :module_sanitized_name
  end

  postgres do
    table "functions"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :file, :string
    attribute :line, :integer

    attribute :arity, :integer do
      allow_nil? false
    end

    attribute :type, :atom do
      constraints one_of: [:function, :macro, :callback, :type]
      allow_nil? false
    end

    attribute :heads, {:array, :string} do
      default []
    end

    attribute :heads_html, {:array, :string} do
      default []
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

    attribute :order, :integer do
      allow_nil? false
    end
  end

  code_interface do
    define_for AshHq.Docs
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      argument :library_version, :uuid

      change manage_relationship(:library_version, type: :append_and_remove)
    end
  end

  aggregates do
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
    first :library_id, [:library_version, :library], :id
    first :module_name, :module, :name
    first :module_sanitized_name, :module, :sanitized_name
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end

    belongs_to :module, AshHq.Docs.Module do
      allow_nil? true
    end
  end
end
