defmodule AshHq.Docs.Guide do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  render_markdown do
    render_attributes text: :text_html
  end

  search do
    doc_attribute :text
    load_for_search library_version: [:library_name, :library_display_name]
  end

  code_interface do
    define_for AshHq.Docs
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      primary? true
      allow_nil_input [:route]
    end
  end

  changes do
    change AshHq.Docs.Guide.Changes.SetRoute
  end

  postgres do
    repo AshHq.Repo
    table "guides"

    references do
      reference :library_version, on_delete: :delete
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :order, :integer do
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
    end

    attribute :text, :string do
      allow_nil? false
      constraints trim?: false, allow_empty?: true
      default ""
    end

    attribute :text_html, :string do
      constraints trim?: false, allow_empty?: true
      writable? false
    end

    attribute :category, :string do
      default "Guides"
      allow_nil? false
    end

    attribute :route, :string do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end
  end
end
