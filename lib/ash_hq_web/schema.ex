defmodule AshHqWeb.Schema do
  @moduledoc "The absinthe graphql schema"
  use Absinthe.Schema

  @domains [AshHq.Docs]

  use AshGraphql, domains: @domains

  query do
  end

  mutation do
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end
end
