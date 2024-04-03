defmodule AshHq.Discord do
  @moduledoc "Discord api import & interactions"
  use Ash.Domain

  resources do
    resource AshHq.Discord.Attachment
    resource AshHq.Discord.Channel
    resource AshHq.Discord.Message
    resource AshHq.Discord.Reaction
    resource AshHq.Discord.Tag
    resource AshHq.Discord.Thread
    resource AshHq.Discord.ThreadTag
  end
end
