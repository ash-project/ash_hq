defmodule AshHq.Docs.Guide do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshHq.Docs.Extensions.Search,
      AshHq.Docs.Extensions.RenderMarkdown,
      AshGraphql.Resource,
      AshAdmin.Resource
    ]

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

    attribute :sanitized_route, :string do
      allow_nil? false
      writable? false
    end

    attribute :default, :boolean do
      default false
      allow_nil? false
    end

    timestamps()
  end

  search do
    doc_attribute :text
    show_docs_on [:sanitized_name, :sanitized_route]
    type "Guides"
    load_for_search library_version: [:library_name, :library_display_name]
  end

  render_markdown do
    render_attributes text: :text_html
    table_of_contents? true
  end

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

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      allow_nil? true
    end
  end

  postgres do
    repo AshHq.Repo
    table "guides"

    references do
      reference :library_version, on_delete: :delete
    end
  end

  actions do
    defaults [:create, :update, :destroy]

    read :read do
      primary? true

      pagination keyset?: true,
                 offset?: true,
                 countable: true,
                 default_limit: 25,
                 required?: false
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

  code_interface do
    define_for AshHq.Docs
  end

  resource do
    description "Represents a markdown guide exposed by a library"
  end

  changes do
    change AshHq.Docs.Guide.Changes.SetRoute

    change fn changeset, _ ->
      if Ash.Changeset.changing_attribute?(changeset, :route) do
        route = Ash.Changeset.get_attribute(changeset, :route)

        Ash.Changeset.force_change_attribute(
          changeset,
          :sanitized_route,
          AshHqWeb.DocRoutes.sanitize_name(route, true)
        )
      else
        changeset
      end
    end
  end
end
