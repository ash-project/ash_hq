defmodule AshHq.Docs.Guide do
  @moduledoc false
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshHq.Docs.Extensions.Search,
      AshHq.Docs.Extensions.RenderMarkdown,
      AshGraphql.Resource,
      AshAdmin.Resource
    ]

  graphql do
    type :guide

    queries do
      list :list_guides, :read_for_version
    end
  end

  admin do
    form do
      field :text do
        type :markdown
      end
    end
  end

  resource do
    description "Represents a markdown guide exposed by a library"
  end

  render_markdown do
    render_attributes text: :text_html
  end

  search do
    doc_attribute :text
    type "Guides"
    load_for_search library_version: [:library_name, :library_display_name]
    show_docs_on :route
    sanitized_name_attribute :route
    auto_sanitize_name_attribute? false
  end

  code_interface do
    define_for AshHq.Docs
  end

  actions do
    defaults [:create, :update, :destroy]

    read :read do
      primary? true
      pagination offset?: true, countable: true, default_limit: 25, required?: false
    end

    read :read_for_version do
      argument :library_versions, {:array, :uuid} do
        allow_nil? false
        constraints max_length: 20, min_length: 1
      end

      pagination offset?: true, countable: true, default_limit: 25, required?: false

      filter expr(library_version.id in ^arg(:library_versions))
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
      default "Topics"
      allow_nil? false
    end

    attribute :route, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end
  end
end
