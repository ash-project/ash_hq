defmodule AshHq.Docs.Search.Steps.BuildResults do
  @moduledoc """
  Sorts the results of search.
  """
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    {:ok,
     input[:results]
     |> Kernel.||([])
     |> List.flatten()
     |> Enum.reject(&is_nil/1)
     |> Enum.sort_by(
       # false comes first, and we want all things where the name matches to go first
       &{is_forum?(&1), name_is_exactly(&1, input[:query]), -&1.match_rank,
        Map.get(&1, :extension_order, -1), Enum.count(Map.get(&1, :path, []))}
     )}
  end

  defp is_forum?(%AshHq.Discord.Message{}), do: true
  defp is_forum?(_), do: false

  defp name_is_exactly(%resource{} = record, search) do
    if AshHq.Docs.Extensions.Search.has_name_attribute?(resource) do
      # this is inverted because `false < true`
      if attr = AshHq.Docs.Extensions.Search.name_attribute(resource) do
        Map.get(record, attr) != search
      else
        true
      end
    else
      false
    end
  end
end
