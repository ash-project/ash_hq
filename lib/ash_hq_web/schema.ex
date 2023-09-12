defmodule AshHqWeb.Schema do
  @moduledoc "The absinthe graphql schema"
  use Absinthe.Schema

  @apis [AshHq.Docs]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
