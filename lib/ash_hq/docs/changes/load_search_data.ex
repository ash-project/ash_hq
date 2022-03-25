defmodule AshHq.Docs.Preparations.LoadSearchData do
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    query_string = Ash.Query.get_argument(query, :query)

    if query_string do
      query
      |> Ash.Query.load(search_headline: [query: query_string])
      |> Ash.Query.sort(match_rank: {:asc, %{query: query_string}})
      |> Ash.Query.load(match_rank: [query: query_string])
    else
      query
    end
  end
end
