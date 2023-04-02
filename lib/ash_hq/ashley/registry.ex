defmodule AshHq.Ashley.Registry do
  @moduledoc false
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.Ashley.Question
    entry AshHq.Ashley.Conversation
  end
end
