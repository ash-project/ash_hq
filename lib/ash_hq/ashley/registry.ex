defmodule AshHq.Ashley.Registry do
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.Ashley.Question
    entry AshHq.Ashley.Conversation
  end
end
