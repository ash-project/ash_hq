defmodule AshHq.Docs.Registry do
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.Docs.Dsl
    entry AshHq.Docs.Extension
    entry AshHq.Docs.Guide
    entry AshHq.Docs.Library
    entry AshHq.Docs.LibraryVersion
    entry AshHq.Docs.Option
  end
end
