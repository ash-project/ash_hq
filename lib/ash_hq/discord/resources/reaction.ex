defmodule AshHq.Discord.Reaction do
  @moduledoc """
  Reactions store emoji reaction counts.
  """
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :count, :integer do
      allow_nil? false
    end

    attribute :emoji, :string do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :message, AshHq.Discord.Message do
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

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  identities do
    identity :unique_message_emoji, [:emoji, :message_id]
  end
end
