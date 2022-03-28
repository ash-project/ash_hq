defmodule AshHq.Docs.Guide do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.Search, AshHq.Docs.Extensions.RenderMarkdown]

  render_markdown do
    render_attributes text: :text_html
  end

  search do
    doc_attribute :text
    load_for_search [:url_safe_name, library_version: [:library_name, :library_display_name]]
  end

  code_interface do
    define_for AshHq.Docs
  end

  postgres do
    repo AshHq.Repo
    table "guides"
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
  end

  calculations do
    calculate :url_safe_name, :string, expr(fragment("replace(?, ' ', '-')", name))
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end
  end
end
