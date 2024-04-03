defmodule AshHq.Discord.ThreadTag do
  @moduledoc "Joins a thread to a tag"
  use Ash.Resource,
    domain: AshHq.Discord,
    data_layer: AshPostgres.DataLayer

  actions do
    default_accept :*
    defaults [:read, :destroy]

    create :tag do
      upsert? true
    end
  end

  relationships do
    belongs_to :thread, AshHq.Discord.Thread do
      public? true
      primary_key? true
      allow_nil? false
      attribute_type :integer
    end

    belongs_to :tag, AshHq.Discord.Tag do
      public? true
      primary_key? true
      allow_nil? false
      attribute_type :integer
    end
  end

  postgres do
    table "discord_thread_tags"
    repo AshHq.Repo
  end

  code_interface do
    define :tag, args: [:thread_id, :tag_id]
  end
end
