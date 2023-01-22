defmodule AshHq.Discord.Registry do
  @moduledoc false
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.Discord.Attachment
    entry AshHq.Discord.Channel
    entry AshHq.Discord.Message
    entry AshHq.Discord.Reaction
    entry AshHq.Discord.Tag
    entry AshHq.Discord.Thread
    entry AshHq.Discord.ThreadTag
  end
end
