defmodule AshHqWeb.Components.Search do
  use Surface.LiveComponent

  require Ash.Query

  alias AshHqWeb.Routes
  alias Surface.Components.{Form, LiveRedirect}
  alias Surface.Components.Form.{Label, Select}

  prop open, :boolean, default: false
  prop close, :event, required: true
  prop libraries, :list, required: true
  prop selected_versions, :map, required: true
  prop change_versions, :event, required: true

  data versions, :map, default: %{}
  data search, :string, default: ""
  data results, :map, default: %{}
  data selected_item, :string

  def render(assigns) do
    ~F"""
    <div
      id={@id}
      style="display: none;"
      class="transition absolute flex justify-center align-middle w-screen h-screen backdrop-blur-sm pb-8 bg-white bg-opacity-10"
      phx-hook="CmdK"
    >
      <div
        :on-click-away={AshHqWeb.AppViewLive.toggle_search()}
        class="dark:text-white absolute rounded-xl left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 w-3/4 h-3/4 bg-white dark:bg-primary-black border-2 dark:border-gray-900"
        :on-window-keydown="select-previous"
        phx-key="ArrowUp"
      >
        <div class="h-full px-6 my-6" :on-window-keydown="select-next" phx-key="ArrowDown">
          <div
            class="w-full flex flex-row justify-start sticky top-0 pb-3 border-b border-gray-600"
            :on-window-keydown="go-to-doc"
            phx-key="Enter"
          >
            <Heroicons.Outline.SearchIcon class="h-6 w-6 mr-4 ml-4" />
            <div class="flex flex-row justify-between w-full">
              <Form for={:search} change="search" class="w-full">
                <input
                  id="search-input"
                  name="search"
                  class="text-lg bg-primary-black grow ring-0 outline-none w-full"
                />
              </Form>
              <button id="close-search" class="mr-4 ml-4 h-6 w-6 hover:text-gray-400" :on-click={@close}>
                <Heroicons.Outline.XIcon class="h-6 w-6" />
              </button>
            </div>
          </div>
          <div class="grid grid-cols-9 h-[85%] mt-3">
            <div class="col-span-3 md:col-span-2 xl:col-span-1 border-r border-gray-600">
              <Form for={:versions} change={@change_versions}>
                {#for library <- @libraries}
                  <Label field={library.id}>
                    {library.display_name}
                  </Label>
                  <div>
                    <Select
                      class="text-black"
                      name={"versions[#{library.id}]"}
                      selected={Map.get(@selected_versions, library.id)}
                      options={Enum.map(library.versions, &{&1.version, &1.id})}
                    />
                  </div>
                {/for}
              </Form>
            </div>
            <div class="pl-4 overflow-y-auto col-span-6 md:col-span-7 xl:col-span-8">
              {render_groups(assigns, @results)}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_groups(assigns, results, first? \\ true) do
    ~F"""
    {#for {group, results} <- results}
      <div class={"ml-4": !first?}>
        {#if first?}
          <div class="font-medium text-lg">
            {group}
          </div>
        {/if}
        {#if Enum.empty?(results.items)}
          {render_results(assigns, results)}
        {#else}
          <div class={"mt-4", "border-l border-gray-700 pl-2": !first?}>
            {render_results(assigns, results)}
          </div>
        {/if}
      </div>
    {/for}
    """
  end

  defp render_results(assigns, results) do
    ~F"""
    <div>
      <div class="font-medium mb-1">
        {#if Map.get(results, :path, []) != []}
          <div class="flex flex-row justify-start align-middle items-center text-center">
            {#for path_item <- Map.get(results, :path, [])}
              <Heroicons.Solid.ChevronRightIcon class="h-6 w-6" />
              <div>
                {path_item}
              </div>
            {/for}
          </div>
        {/if}
      </div>
      {#for item <- results.items}
        <LiveRedirect to={Routes.doc_link(item)}>
          <div
            id={item.id}
            class={
              "rounded-lg mb-4 py-4 px-2 hover:bg-gray-600",
              "bg-gray-600": @selected_item.id == item.id,
              "bg-gray-800": @selected_item.id != item.id
            }
          >
            {#if item.__struct__ != AshHq.Docs.LibraryVersion && item.name != List.last(Map.get(results, :path, []))}
              {item.name}
            {/if}
            {#if item.__struct__ == AshHq.Docs.LibraryVersion}
              {item.version}
            {/if}
            <div class="text-gray-400">
              {raw(item.search_headline)}
            </div>
          </div>
        </LiveRedirect>
      {/for}
      {render_groups(assigns, results.further, false)}
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, socket |> assign(:search, search) |> search()}
  end

  def handle_event("select-next", _, socket) do
    if socket.assigns[:selected_item] && socket.assigns[:item_list] do
      next =
        socket.assigns.item_list
        |> Enum.drop_while(&(&1.id != socket.assigns.selected_item.id))
        |> Enum.at(1)

      {:noreply, set_selected_item(socket, next)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("select-previous", _, socket) do
    if socket.assigns[:selected_item] && socket.assigns[:item_list] do
      next =
        socket.assigns.item_list
        |> Enum.reverse()
        |> Enum.drop_while(&(&1.id != socket.assigns.selected_item.id))
        |> Enum.at(1)

      {:noreply, set_selected_item(socket, next)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("go-to-doc", _, socket) do
    case Enum.find(socket.assigns.item_list, fn item ->
           item.id == socket.assigns.selected_item.id
         end) do
      nil ->
        {:noreply, socket}

      item ->
        {:noreply, redirect(socket, to: Routes.doc_link(item))}
    end
  end

  defp search(socket) do
    if socket.assigns[:search] in [nil, ""] || socket.assigns[:selected_versions] in [nil, %{}] do
      assign(socket, :results, %{})
    else
      search_results =
        AshHq.Docs
        |> Ash.Api.resources()
        |> Enum.filter(&(AshHq.Docs.Extensions.Search in Ash.Resource.Info.extensions(&1)))
        |> Enum.flat_map(fn resource ->
          to_load = AshHq.Docs.Extensions.Search.load_for_search(resource)

          resource.search!(socket.assigns.search, Map.values(socket.assigns.selected_versions),
            query: Ash.Query.limit(resource, 25),
            load: to_load
          )
        end)
        |> Enum.sort_by(
          &{-&1.match_rank, Map.get(&1, :extension_order, -1), Enum.count(Map.get(&1, :path, []))}
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

          %AshHq.Docs.Guide{
            library_version: %{version: version, library_display_name: library_display_name}
          } ->
            "#{library_display_name} #{version}"

          %AshHq.Docs.LibraryVersion{library_display_name: library_display_name, version: version} ->
            "#{library_display_name} #{version}"
        end)
        |> Enum.sort_by(fn {_type, items} ->
          items
          |> Enum.map(&Map.get(sort_rank, &1.id))
          |> Enum.min()
        end)
        |> Enum.map(fn {type, items} ->
          {type, group_by_paths(items)}
        end)

      item_list = item_list(results)
      selected_item = Enum.at(item_list, 0)

      socket
      |> assign(:results, results)
      |> assign(:item_list, item_list)
      |> set_selected_item(selected_item)
    end
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

  defp set_selected_item(socket, nil), do: socket

  defp set_selected_item(socket, selected_item) do
    socket
    |> assign(:selected_item, selected_item)
    |> push_event("js:scroll-to", %{id: selected_item.id, boundary_id: socket.assigns[:id]})
  end

  defp group_by_paths(items) do
    items
    |> Enum.map(&{Map.get(&1, :path, []), &1})
    |> do_group_by_paths()
  end

  defp do_group_by_paths(items, path_acc \\ []) do
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
      |> Enum.map(fn {nested, items} ->
        {nested, do_group_by_paths(items, path_acc ++ [nested])}
      end)

    %{path: path_acc, items: Enum.map(items_for_group, &elem(&1, 1)), further: further_items}
  end
end
