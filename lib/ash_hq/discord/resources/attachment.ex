defmodule AshHq.Discord.Attachment do
  @moduledoc "A discord attachment on a message"
  use Ash.Resource,
    domain: AshHq.Discord,
    data_layer: AshPostgres.DataLayer

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key :id, generated?: false, writable?: true
    attribute :filename, :string, public?: true
    attribute :size, :integer, public?: true
    attribute :url, :string, public?: true
    attribute :proxy_url, :string, public?: true
    attribute :height, :integer, public?: true
    attribute :width, :integer, public?: true
  end

  relationships do
    belongs_to :message, AshHq.Discord.Message do
      public? true
      allow_nil? false
      attribute_type :integer
    end
  end

  postgres do
    table "discord_attachments"
    repo AshHq.Repo

    references do
      reference :message, on_delete: :delete, on_update: :update
    end
  end
end
