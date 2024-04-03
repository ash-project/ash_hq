defmodule AshHq.Discord.Reaction do
  @moduledoc """
  Reactions store emoji reaction counts.
  """
  use Ash.Resource,
    domain: AshHq.Discord,
    data_layer: AshPostgres.DataLayer

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :count, :integer do
      public? true
      allow_nil? false
    end

    attribute :emoji, :string do
      public? true
      allow_nil? false
    end
  end

  relationships do
    belongs_to :message, AshHq.Discord.Message do
      public? true
      attribute_type :integer
      allow_nil? false
    end
  end

  postgres do
    table "discord_reactions"
    repo AshHq.Repo

    references do
      reference :message, on_delete: :delete, on_update: :update
    end
  end

  identities do
    identity :unique_message_emoji, [:emoji, :message_id]
  end
end
