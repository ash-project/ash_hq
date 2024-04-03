defmodule AshHq.Discord.Tag do
  @moduledoc "A tag that can be applied to a post. Currently uses CSV data layer and therefore is static"
  use Ash.Resource,
    domain: AshHq.Discord,
    data_layer: AshPostgres.DataLayer

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]

    create :upsert do
      upsert? true
      upsert_identity :unique_name_per_channel
    end
  end

  attributes do
    integer_primary_key :id, generated?: false, writable?: true

    attribute :name, :ci_string do
      public? true
      allow_nil? false
    end
  end

  relationships do
    belongs_to :channel, AshHq.Discord.Channel do
      public? true
      attribute_type :integer
    end
  end

  postgres do
    table "discord_tags"
    repo AshHq.Repo
  end

  code_interface do
    define :upsert, args: [:channel_id, :id, :name]
    define :read
    define :destroy
  end

  identities do
    identity :unique_name_per_channel, [:name, :channel_id]
  end
end
