defmodule AshHq.Docs.Search.Steps.BuildResults do
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    search_results =
      input
      |> Map.values()
      |> List.flatten()
      |> Enum.sort_by(
        # false comes first, and we want all things where the name matches to go first
        &{name_match_rank(&1), -&1.match_rank, Map.get(&1, :extension_order, -1),
         Enum.count(Map.get(&1, :path, []))}
      )

    sort_rank =
      search_results
      |> Enum.with_index()
      |> Map.new(fn {item, i} ->
        {item.id, i}
      end)

    results =
      search_results
      |> Enum.group_by(fn
        %{extension_type: type} ->
          type

        %AshHq.Docs.Function{module_name: module_name} ->
          module_name

        %AshHq.Docs.Module{name: name} ->
          name

        %AshHq.Docs.Guide{
          library_version: %{version: version, library_display_name: library_display_name}
        } ->
          "#{library_display_name} #{version}"

        %AshHq.Docs.Extension{
          library_version: %{version: version, library_display_name: library_display_name}
        } ->
          "#{library_display_name} #{version}"

        %AshHq.Docs.LibraryVersion{library_display_name: library_display_name, version: version} ->
          "#{library_display_name} #{version}"

        other ->
          raise "Nothing matching #{inspect(other)}"
      end)
      |> Enum.sort_by(fn {_type, items} ->
        items
        |> Enum.map(&Map.get(sort_rank, &1.id))
        |> Enum.min()
      end)
      |> Enum.map(fn {type, items} ->
        {type, group_by_paths(items, sort_rank)}
      end)

    item_list = item_list(results)

    {:ok, %{item_list: item_list, results: results}}
  end

  defp item_list(results) do
    List.flatten(do_item_list(results))
  end

  defp do_item_list({_key, %{items: items, further: further}}) do
    do_item_list(items) ++ do_item_list(further)
  end

  defp do_item_list(items) when is_list(items) do
    Enum.map(items, &do_item_list/1)
  end

  defp do_item_list(item), do: item

  defp group_by_paths(items, sort_rank) do
    items
    |> Enum.map(&{Map.get(&1, :path, []), &1})
    |> do_group_by_paths(sort_rank)
  end

  defp do_group_by_paths(items, sort_rank, path_acc \\ []) do
    {items_for_group, further} =
      Enum.split_with(items, fn
        {[], _} ->
          true

        _ ->
          false
      end)

    further_items =
      further
      |> Enum.group_by(
        fn {[next | _rest], _item} ->
          next
        end,
        fn {[_next | rest], item} ->
          {rest, item}
        end
      )
      |> Enum.sort_by(fn {_nested, items} ->
        items
        |> Enum.map(&elem(&1, 1))
        |> Enum.sort_by(&Map.get(sort_rank, &1.id))
      end)
      |> Enum.map(fn {nested, items} ->
        {nested, do_group_by_paths(items, sort_rank, path_acc ++ [nested])}
      end)

    items =
      items_for_group
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort_by(&Map.get(sort_rank, &1.id))

    %{path: path_acc, items: items, further: further_items}
  end

  defp name_match_rank(record) do
    if record.name_matches do
      -search_length(record)
    else
      0
    end
  end

  defp search_length(%resource{} = record) do
    case AshHq.Docs.Extensions.Search.doc_attribute(resource) do
      nil ->
        0

      doc_attribute ->
        String.length(Map.get(record, doc_attribute))
    end
  end
end
