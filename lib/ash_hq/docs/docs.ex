defmodule AshHq.Docs do
  @moduledoc """
  Handles documentation data.
  """
  use Ash.Api,
    extensions: [
      AshGraphql.Api
    ]

  execution do
    timeout 30_000
  end

  resources do
    registry AshHq.Docs.Registry
  end
end
