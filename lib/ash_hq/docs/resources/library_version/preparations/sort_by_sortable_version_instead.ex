defmodule AshHq.Docs.LibraryVersion.Preparations.SortBySortableVersionInstead do
  @moduledoc """
  Replaces any sort on `version` by a sort on `sortable_version` instead.
  """
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    %{query | sort: replace_sort(query.sort)}
  end

  defp replace_sort(nil), do: nil
  defp replace_sort(:version), do: :sortable_version
  defp replace_sort({:version, order}), do: {:sortable_version, order}
  defp replace_sort(list) when is_list(list), do: Enum.map(list, &replace_sort/1)
  defp replace_sort(other), do: other
end
