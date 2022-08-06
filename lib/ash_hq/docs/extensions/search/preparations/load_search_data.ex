defmodule AshHq.Extensions.Search.Preparations.LoadSearchData do
  @moduledoc """
  Ensures that any data needed for search results is loaded.
  """
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    query_string = Ash.Query.get_argument(query, :query)
    to_load = AshHq.Docs.Extensions.Search.load_for_search(query.resource)

    if query_string do
      query
      |> Ash.Query.load(
        search_headline: [query: query_string],
        match_rank: [query: query_string],
        name_matches: [query: query_string, similarity: 0.7]
      )
      |> Ash.Query.load(to_load)
      |> Ash.Query.sort(match_rank: {:asc, %{query: query_string}})
    else
      query
    end
  end
end
