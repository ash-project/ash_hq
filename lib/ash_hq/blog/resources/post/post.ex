defmodule AshHq.Blog.Post do
  @moduledoc "A blog post. Uses the AshBlog data layer and therefore is static"
  use Ash.Resource,
    otp_app: :ash_hq,
    data_layer: AshBlog.DataLayer,
    extensions: [AshHq.Docs.Extensions.RenderMarkdown, AshAdmin.Resource]

  require Ash.Query

  render_markdown do
    render_attributes body: :body_html
  end

  admin do
    table_columns [:slug, :title, :state, :created_at, :id]

    form do
      field :body do
        type :markdown
      end
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :tag_line, :string do
      allow_nil? false
      constraints max_length: 250
    end

    attribute :tag_names, {:array, :ci_string} do
      constraints items: [
                    match: ~r/^[a-zA-Z]*$/,
                    casing: :lower
                  ]
    end

    attribute :author, :string do
      allow_nil? false
    end

    attribute :body_html, :string do
      writable? false
    end

    timestamps()
  end

  relationships do
    has_many :tags, AshHq.Blog.Tag do
      manual fn posts, %{query: query} ->
        all_tags = Enum.flat_map(posts, & &1.tag_names)

        tags =
          query
          |> Ash.Query.unset([:limit, :offset])
          |> Ash.Query.filter(name in ^all_tags)
          |> AshHq.Blog.read!()

        {:ok,
         Map.new(posts, fn post ->
           {post.id, Enum.filter(tags, &(&1.name in post.tag_names))}
         end)}
      end
    end
  end

  actions do
    defaults [:create, :read, :update]

    read :published do
      argument :tag, :ci_string

      filter expr(
               state == :published and
                 if is_nil(^arg(:tag)) do
                   true
                 else
                   ^arg(:tag) in type(tag_names, ^{:array, :ci_string})
                 end
             )
    end

    read :by_slug do
      argument :slug, :string do
        allow_nil? false
      end

      get? true

      filter expr(slug == ^arg(:slug) or ^arg(:slug) in past_slugs)
    end
  end

  code_interface do
    define_for AshHq.Blog
    define :published
    define :by_slug, args: [:slug]
  end

  changes do
    change fn changeset, _ ->
             Ash.Changeset.after_action(changeset, fn _, %{tag_names: tag_names} = record ->
               all_post_tags =
                 __MODULE__.published!()
                 |> Enum.flat_map(& &1.tag_names)

               notifications =
                 Enum.flat_map(
                   tag_names,
                   &elem(AshHq.Blog.Tag.upsert!(&1, return_notifications?: true), 1)
                 )

               destroy_notifications =
                 AshHq.Blog.Tag.read!()
                 |> Enum.flat_map(fn tag ->
                   if to_string(tag.name) in all_post_tags do
                     []
                   else
                     AshHq.Blog.Tag.destroy!(tag, return_notifications?: true)
                   end
                 end)

               {:ok, record, notifications ++ destroy_notifications}
             end)
           end,
           on: [:create, :update]
  end
end
