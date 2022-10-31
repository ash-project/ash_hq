defmodule AshHqWeb.Schema do
  use Absinthe.Schema

  @apis [AshHq.Docs]

  use AshGraphql, apis: @apis

  query do
  end

  def context(ctx) do
    AshGraphql.add_context(ctx, @apis)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
