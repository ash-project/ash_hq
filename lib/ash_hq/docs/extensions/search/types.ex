defmodule AshHq.Docs.Extensions.Search.Types do
  @moduledoc """
  A static list of all search types that currently exist
  """

  @search_types AshHq.Docs.Registry
                |> Ash.Registry.Info.entries()
                |> Enum.filter(&(AshHq.Docs.Extensions.Search in Spark.extensions(&1)))
                |> Enum.map(&AshHq.Docs.Extensions.Search.type/1)
                |> Enum.uniq()

  def types do
    @search_types
  end
end
