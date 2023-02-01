defmodule AshHq.Extensions.Search.Preparations.LoadSearchData do
  @moduledoc """
  Ensures that any data needed for search results is loaded.
  """
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    query_string = Ash.Query.get_argument(query, :query)
    to_load = AshHq.Docs.Extensions.Search.load_for_search(query.resource)

    query.resource
    |> AshHq.Docs.Extensions.RenderMarkdown.render_attributes()
    |> Enum.reduce(query, fn {source, target}, query ->
      Ash.Query.deselect(query, [source, target])
    end)
    |> Ash.Query.load(search_headline: [query: query_string])
    |> Ash.Query.load(match_rank: [query: query_string])
    |> Ash.Query.load(to_load)
    |> Ash.Query.sort(match_rank: {:asc, %{query: query_string}})
  end
end
