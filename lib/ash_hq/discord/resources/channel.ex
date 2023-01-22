defmodule AshHq.Discord.Channel do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "discord_channels"
    repo AshHq.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    create :upsert do
      upsert? true
    end
  end

  code_interface do
    define_for AshHq.Discord
    define :read
    define :upsert
  end

  attributes do
    integer_primary_key :id, writable?: true, generated?: false

    attribute :name, :string do
      allow_nil? false
    end

    attribute :order, :integer do
      allow_nil? false
    end
  end

  relationships do
    has_many :threads, AshHq.Discord.Thread
  end
end
