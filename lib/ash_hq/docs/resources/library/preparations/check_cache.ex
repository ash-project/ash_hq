defmodule AshHq.Docs.Library.Preparations.CheckCache do
  use Ash.Resource.Preparation

  def prepare(query, _, _) when query.arguments.check_cache == true do
    Ash.Query.before_action(query, fn query ->
      AshHq.Docs
      |> Ash.Filter.Runtime.filter_matches(
        AshHq.Docs.Library.Agent.get(),
        query.filter
      )
      |> case do
        {:ok, results} ->
          results =
            results
            |> then(fn results ->
              if query.offset do
                Enum.drop(results, query.offset)
              else
                results
              end
            end)
            |> then(fn results ->
              if query.limit do
                Enum.take(results, query.limit)
              else
                results
              end
            end)
            |> Ash.Sort.runtime_sort(query.sort)

          Ash.Query.set_result(query, {:ok, results})

        {:error, _} ->
          query
      end
    end)
  end

  def prepare(query, _, _) do
    query
  end
end
