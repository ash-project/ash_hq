defmodule AshHq.Discord.Attachment do
  @moduledoc "A discord attachment on a message"
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "discord_attachments"
    repo AshHq.Repo
  end

  actions do
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key :id, generated?: false, writable?: true
    attribute :filename, :string
    attribute :size, :integer
    attribute :url, :string
    attribute :proxy_url, :string
    attribute :height, :integer
    attribute :width, :integer
  end

  relationships do
    belongs_to :message, AshHq.Discord.Message do
      allow_nil? false
      attribute_type :integer
    end
  end
end
