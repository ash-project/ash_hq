defmodule AshHq.Discord.Reaction do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "discord_reactions"
    repo AshHq.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :count, :integer do
      allow_nil? false
    end

    attribute :emoji, :string do
      allow_nil? false
    end
  end

  identities do
    identity :unique_message_emoji, [:emoji, :message_id]
  end

  relationships do
    belongs_to :message, AshHq.Discord.Message do
      attribute_type :integer
      allow_nil? false
    end
  end
end
