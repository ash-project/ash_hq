defmodule AshHqWeb.Schema do
  use Absinthe.Schema

  # The registry must be included alongside the api to ensure the schema is properly recompiled on changes.
  @apis [{AshHq.Docs, AshHq.Docs.Registry}]

  use AshGraphql, apis: @apis

  def context(ctx) do
    AshGraphql.add_context(ctx, @apis)
  end

  def plugins() do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
