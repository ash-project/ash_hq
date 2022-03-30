defmodule AshHq.Docs.Extensions.Search.Types do
  @search_types AshHq.Docs
                |> Ash.Api.resources()
                |> Enum.filter(
                  &(AshHq.Docs.Extensions.Search in Ash.Resource.Info.extensions(&1))
                )
                |> Enum.map(&AshHq.Docs.Extensions.Search.type/1)
                |> Enum.uniq()

  def types() do
    @search_types
  end
end
