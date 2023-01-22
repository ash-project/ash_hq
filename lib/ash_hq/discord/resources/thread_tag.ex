defmodule AshHq.Discord.ThreadTag do
  @moduledoc "Joins a thread to a tag"
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "discord_thread_tags"
    repo AshHq.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :tag do
      upsert? true
    end
  end

  code_interface do
    define_for AshHq.Discord
    define :tag, args: [:thread_id, :tag_id]
  end

  relationships do
    belongs_to :thread, AshHq.Discord.Thread do
      primary_key? true
      allow_nil? false
      attribute_writable? true
      attribute_type :integer
    end

    belongs_to :tag, AshHq.Discord.Tag do
      primary_key? true
      allow_nil? false
      attribute_writable? true
      attribute_type :integer
    end
  end
end
