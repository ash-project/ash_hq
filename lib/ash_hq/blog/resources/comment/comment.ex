defmodule AshHq.Blog.Comment do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.RenderMarkdown]

  render_markdown do
    render_attributes text: :text_html
  end

  postgres do
    table "comments"
    repo AshHq.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :text, :string do
      allow_nil? false
    end

    attribute :text_html, :string do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :author, AshHq.Accounts.User do
      allow_nil? false
      api AshHq.Accounts
    end
  end
end
