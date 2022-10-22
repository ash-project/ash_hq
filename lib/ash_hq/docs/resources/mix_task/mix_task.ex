defmodule AshHq.Docs.MixTask do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  resource do
    description "Represents a mix task that has been exposed by a library"
  end

  render_markdown do
    render_attributes doc: :doc_html
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

  postgres do
    table "mix_tasks"
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

    attribute :category, :string do
      allow_nil? false
      default "Misc"
    end

    attribute :file, :string

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

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25, required?: false
    end

    create :create do
      primary? true
      argument :library_version, :uuid

      change manage_relationship(:library_version, type: :append_and_remove)
    end
  end

  code_interface do
    define_for AshHq.Docs
  end

  aggregates do
    first :version_name, :library_version, :version
    first :library_name, [:library_version, :library], :name
    first :library_id, [:library_version, :library], :id
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end
  end
end
