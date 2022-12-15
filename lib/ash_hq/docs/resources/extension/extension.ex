defmodule AshHq.Docs.Extension do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  postgres do
    table "extensions"
    repo AshHq.Repo

    references do
      reference :library_version, on_delete: :delete
    end
  end

  search do
    doc_attribute :doc
    load_for_search library_version: [:library_display_name, :library_name]
  end

  render_markdown do
    render_attributes doc: :doc_html
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :target, :string

    attribute :default_for_target, :boolean do
      default false
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

    attribute :type, :string do
      allow_nil? false
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

    has_many :dsls, AshHq.Docs.Dsl
    has_many :options, AshHq.Docs.Option
  end

  actions do
    defaults [:update, :destroy]

    read :read do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25, required?: false
    end

    create :create do
      primary? true

      argument :library_version, :uuid do
        allow_nil? false
      end

      argument :dsls, {:array, :map}
      change manage_relationship(:library_version, type: :append_and_remove)
      change {AshHq.Docs.Changes.AddArgToRelationship, arg: :library_version, rel: :dsls}

      change {AshHq.Docs.Changes.AddArgToRelationship,
              attr: :id, arg: :extension_id, rel: :dsls, generate: &Ash.UUID.generate/0}

      change manage_relationship(:dsls, type: :create)
    end
  end

  code_interface do
    define_for AshHq.Docs

    define :destroy
  end

  resource do
    description "An Ash DSL extension."
  end

  identities do
    identity :unique_name_by_library_version, [:name, :library_version_id]
  end
end
