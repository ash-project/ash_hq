defmodule AshHq.Discord.Message do
  @moduledoc """
  Represents all of the messages on a given forum post/thread.
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshHq.Docs.Extensions.RenderMarkdown, AshHq.Docs.Extensions.Search]

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      argument :attachments, {:array, :map}
      argument :reactions, {:array, :map}
      change manage_relationship(:attachments, type: :direct_control)

      change manage_relationship(:reactions,
               type: :direct_control,
               use_identities: [:unique_message_emoji]
             )
    end

    update :update do
      primary? true
      argument :attachments, {:array, :map}
      argument :reactions, {:array, :map}
      change manage_relationship(:attachments, type: :direct_control)

      change manage_relationship(:reactions,
               type: :direct_control,
               use_identities: [:unique_message_emoji]
             )
    end
  end

  render_markdown do
    render_attributes content: :content_html
  end

  search do
    doc_attribute :content

    type "Forum"

    load_for_search [
      :channel_name,
      :thread_name
    ]

    has_name_attribute? false
    weight_content(-0.7)
  end

  attributes do
    integer_primary_key :id, generated?: false, writable?: true

    attribute :author, :string do
      allow_nil? false
    end

    attribute :content, :string
    attribute :content_html, :string

    attribute :timestamp, :utc_datetime do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :thread, AshHq.Discord.Thread do
      attribute_type :integer
      allow_nil? false
    end

    has_many :attachments, AshHq.Discord.Attachment
    has_many :reactions, AshHq.Discord.Reaction
  end

  postgres do
    table "discord_messages"
    repo AshHq.Repo

    references do
      reference :thread, on_delete: :delete, on_update: :update
    end
  end

  aggregates do
    first :channel_name, [:thread, :channel], :name
    first :thread_name, [:thread], :name
  end
end
