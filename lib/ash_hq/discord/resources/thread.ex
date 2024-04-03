defmodule AshHq.Discord.Thread do
  @moduledoc """
  A thread is an individual forum post (because they are really just fancy threads)
  """

  use Ash.Resource,
    domain: AshHq.Discord,
    data_layer: AshPostgres.DataLayer

  import Ecto.Query

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]

    read :feed do
      pagination do
        countable true
        offset? true
        default_limit 25
      end

      argument :channel, :integer do
        allow_nil? false
      end

      argument :tag_name, :string

      prepare build(sort: [create_timestamp: :desc])

      filter expr(
               channel_id == ^arg(:channel) and
                 (is_nil(^arg(:tag_name)) or tags.name == ^arg(:tag_name))
             )
    end

    create :upsert do
      upsert? true
      argument :messages, {:array, :map}
      argument :tags, {:array, :integer}

      change manage_relationship(:messages, type: :direct_control)

      change fn changeset, _ ->
        Ash.Changeset.after_action(changeset, fn changeset, thread ->
          tags = Ash.Changeset.get_argument(changeset, :tags) || []

          # Not optimized in `manage_relationship`
          # bulk actions should make this unnecessary
          to_delete =
            from thread_tag in AshHq.Discord.ThreadTag,
              where: thread_tag.thread_id == ^thread.id,
              where: thread_tag.tag_id not in ^tags

          AshHq.Repo.delete_all(to_delete)

          Enum.map(tags, fn tag ->
            AshHq.Discord.ThreadTag.tag!(thread.id, tag)
          end)

          {:ok, thread}
        end)
      end
    end
  end

  attributes do
    integer_primary_key :id, generated?: false, writable?: true
    attribute :type, :integer do
      public? true
    end

    attribute :name, :string do
      public? true
      allow_nil? false
    end

    attribute :author, :string do
      public? true
      allow_nil? false
    end

    attribute :create_timestamp, :utc_datetime do
      public? true
      allow_nil? false
    end
  end

  relationships do
    has_many :messages, AshHq.Discord.Message do
      public? true
    end

    belongs_to :channel, AshHq.Discord.Channel do
      public? true
      attribute_type :integer
      allow_nil? false
    end

    many_to_many :tags, AshHq.Discord.Tag do
      public? true
      through AshHq.Discord.ThreadTag
      source_attribute_on_join_resource :thread_id
      destination_attribute_on_join_resource :tag_id
    end
  end

  postgres do
    table "discord_threads"
    repo AshHq.Repo
  end

  code_interface do
    define :upsert
    define :by_id, action: :read, get_by: [:id]
    define :feed, args: [:channel]
  end
end
