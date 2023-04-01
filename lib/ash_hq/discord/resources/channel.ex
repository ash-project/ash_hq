defmodule AshHq.Discord.Channel do
  @moduledoc """
  The channel is the discord forum channel. We explicitly configure which ones we import.
  """

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:create, :read, :update, :destroy]

    create :upsert do
      upsert? true
    end
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

  postgres do
    table "discord_channels"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Discord
    define :read
    define :upsert
  end
end
