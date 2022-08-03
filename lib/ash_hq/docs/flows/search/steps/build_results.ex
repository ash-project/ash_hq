defmodule AshHq.Docs.Search.Steps.BuildResults do
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    # search_results =
    {:ok,
     input
     |> Map.values()
     |> List.flatten()
     |> Enum.sort_by(
       # false comes first, and we want all things where the name matches to go first
       &{name_match_rank(&1), -&1.match_rank, Map.get(&1, :extension_order, -1),
        Enum.count(Map.get(&1, :path, []))}
     )}
  end

  defp name_match_rank(record) do
    if record.name_matches do
      -search_length(record)
    else
      0
    end
  end

  defp search_length(%resource{} = record) do
    case AshHq.Docs.Extensions.Search.name_attribute(resource) do
      nil ->
        0

      doc_attribute ->
        String.length(Map.get(record, doc_attribute))
    end
  end
end
