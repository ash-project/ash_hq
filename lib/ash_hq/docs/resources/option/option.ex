defmodule AshHq.Docs.Option do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  render_markdown do
    render_attributes doc: :doc_html
  end

  search do
    load_for_search [
      :extension_order,
      :extension_type,
      :extension_name,
      :version_name,
      :library_name,
      :library_id
    ]
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

    attribute :default, :string
    attribute :path, {:array, :string}
    attribute :order, :integer, allow_nil?: false
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      argument :library_version, :uuid

      argument :extension_id, :uuid do
        allow_nil? false
      end

      change manage_relationship(:extension_id, :extension, type: :replace)
      change manage_relationship(:library_version, type: :replace)
    end
  end

  aggregates do
    first :extension_type, [:dsl, :extension], :type
    first :extension_name, [:dsl, :extension], :name
    first :extension_order, [:dsl, :extension], :order
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
    first :library_id, [:library_version, :library], :id
  end

  relationships do
    belongs_to :dsl, AshHq.Docs.Dsl do
      required? true
    end

    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end

    belongs_to :extension, AshHq.Docs.Extension do
      required? true
    end
  end
end
