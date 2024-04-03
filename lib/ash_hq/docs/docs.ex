defmodule AshHq.Docs do
  @moduledoc """
  Handles documentation data.
  """
  use Ash.Domain,
    extensions: [
      AshGraphql.Domain,
      AshAdmin.Domain
    ]

  admin do
    show? true
    default_resource_page :primary_read
  end

  execution do
    timeout 30_000
  end

  resources do
    resource AshHq.Docs.Dsl
    resource AshHq.Docs.Extension
    resource AshHq.Docs.Function
    resource AshHq.Docs.Guide
    resource AshHq.Docs.Library
    resource AshHq.Docs.LibraryVersion
    resource AshHq.Docs.MixTask
    resource AshHq.Docs.Module
    resource AshHq.Docs.Option
  end
end
