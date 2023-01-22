defmodule AshHq.Discord.Tag do
  @moduledoc "A tag that can be applied to a post. Currently uses CSV data layer and therefore is static"
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "discord_tags"
    repo AshHq.Repo
  end

  attributes do
    integer_primary_key :id, generated?: false, writable?: true

    attribute :name, :ci_string do
      allow_nil? false
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    create :upsert do
      upsert? true
      upsert_identity :unique_name_per_channel
    end
  end

  identities do
    identity :unique_name_per_channel, [:name, :channel_id]
  end

  code_interface do
    define_for AshHq.Discord
    define :upsert, args: [:channel_id, :id, :name]
    define :read
    define :destroy
  end

  relationships do
    belongs_to :channel, AshHq.Discord.Channel do
      attribute_type :integer
      attribute_writable? true
    end
  end
end
