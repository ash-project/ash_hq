defmodule AshHq.Docs.Function do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  render_markdown do
    render_attributes(doc: :doc_html)
    header_ids?(false)
  end

  search do
    load_for_search([
      :version_name,
      :library_name,
      :module_name
    ])

    type "Code"
  end

  postgres do
    table "functions"
    repo AshHq.Repo

    references do
      reference(:library_version, on_delete: :delete)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :arity, :integer do
      allow_nil? false
    end

    attribute :type, :atom do
      constraints one_of: [:function, :macro, :callback]
      allow_nil? false
    end

    attribute :heads, {:array, :string} do
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

      change manage_relationship(:library_version, type: :replace)
    end
  end

  aggregates do
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
    first :module_name, :module, :name
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end

    belongs_to :module, AshHq.Docs.Module do
      required? true
    end
  end
end
