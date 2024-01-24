defmodule AshHq.Docs.MixTask do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true

      pagination keyset?: true,
                 offset?: true,
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
      :library_id
    ]

    item_type "Mix Task"

    type "Mix Tasks"
  end

  render_markdown do
    render_attributes doc: :doc_html
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :category, :string do
      allow_nil? false
      default "Misc"
    end

    attribute :file, :string

    attribute :module_name, :string

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

    timestamps()
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end
  end

  postgres do
    table "mix_tasks"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
    end
  end

  code_interface do
    define_for AshHq.Docs
  end

  resource do
    description "Represents a mix task that has been exposed by a library"
  end

  calculations do
    calculate :version_name, :string, expr(library_version.version)
    calculate :library_name, :string, expr(library_version.library.name)
    calculate :library_id, :uuid, expr(library_version.library.id)
  end
end
