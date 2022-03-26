defmodule AshHqWeb.Components.Search do
  use Surface.LiveComponent

  require Ash.Query

  alias Surface.Components.Form
  alias Surface.Components.Form.{Label, Select}

  prop open, :boolean, default: false
  prop close, :event, required: true

  data versions, :map, default: %{}
  data selected_versions, :map, default: %{}
  data search, :string, default: ""
  data results, :map, default: %{}
  data libraries, :list, default: []
  data selected_item, :string

  def render(assigns) do
    ~F"""
    <div
      id={@id}
      style={"display: none;"}
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
          <div class="w-full flex flex-row justify-start sticky top-0 pb-3 border-b border-gray-600">
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
            <div class="col-span-1 border-r border-gray-600">
              <Form for={:versions} change="change_versions">
                {#for library <- @libraries}
                  <Label field={library.id}>
                    {library.name}
                  </Label>
                  <div>
                    <Select
                      class="text-black"
                      name={"versions[#{library.id}]"}
                      options={Enum.map(library.versions, &{&1.version, &1.id})}
                    />
                  </div>
                {/for}
              </Form>
            </div>
            <div class="col-span-8 pl-4 overflow-y-auto">
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
        <div class={"mt-4", "border-l border-gray-700 pl-2": !first?}>
          {render_results(assigns, results)}
        </div>
      </div>
    {/for}
    """
  end

  defp render_results(assigns, results) do
    ~F"""
    <div>
      <div class="font-medium mb-1">
        {#if results.path != []}
          <div class="flex flex-row justify-start align-middle items-center text-center">
            {#for path_item <- results.path}
              <Heroicons.Solid.ChevronRightIcon class="h-6 w-6" />
              <div>
                {path_item}
              </div>
            {/for}
          </div>
        {/if}
      </div>
      {#for item <- results.items}
        <div id={item.id} class={
          "rounded-lg mb-4 py-4 px-2",
          "bg-gray-600": @selected_item == item.id,
          "bg-gray-800": @selected_item != item.id
        }>
          {#if item.name != List.last(results.path)}
            {item.name}
          {/if}
          <div class="text-gray-400">
            {raw(item.search_headline)}
          </div>
        </div>
      {/for}
      {render_groups(assigns, results.further, false)}
    </div>
    """
  end

  def mount(socket) do
    socket =
      AshPhoenix.LiveView.keep_live(
        socket,
        :libraries,
        fn _socket ->
          versions_query =
            AshHq.Docs.LibraryVersion
            |> Ash.Query.sort(version: :desc)
            |> Ash.Query.filter(processed == true)

          AshHq.Docs.Library.read!(load: [versions: versions_query])
        end,
        after_fetch: fn results, socket ->
          socket
          |> assign(
            :selected_versions,
            Map.new(results, fn library ->
              version = Enum.at(library.versions, 0)
              {library.id, version && version.id}
            end)
          )
          |> search()
        end
      )

    {:ok, socket}
  end

  def handle_event("change_versions", %{"versions" => versions}, socket) do
    {:noreply,
     socket
     |> assign(:selected_versions, versions)
     |> search()}
  end

  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, socket |> assign(:search, search) |> search()}
  end

  def handle_event("select-next", _, socket) do
    if socket.assigns[:selected_item] && socket.assigns[:id_list] do
      next =
        socket.assigns.id_list
        |> Enum.drop_while(&(&1 != socket.assigns.selected_item))
        |> Enum.at(1)

      {:noreply, set_selected_item(socket, next)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("select-previous", _, socket) do
    if socket.assigns[:selected_item] && socket.assigns[:id_list] do
      next =
        socket.assigns.id_list
        |> Enum.reverse()
        |> Enum.drop_while(&(&1 != socket.assigns.selected_item))
        |> Enum.at(1)

      {:noreply, set_selected_item(socket, next)}
    else
      {:noreply, socket}
    end
  end

  defp search(socket) do
    if socket.assigns[:search] in [nil, ""] || socket.assigns[:selected_versions] in [nil, %{}] do
      assign(socket, :results, %{})
    else
      docs =
        AshHq.Docs.Dsl.search!(
          socket.assigns.search,
          Map.values(socket.assigns.selected_versions),
          query: Ash.Query.limit(AshHq.Docs.Dsl, 10),
          load: [:extension_type]
        )

      search_results =
        AshHq.Docs.Option.search!(
          socket.assigns.search,
          Map.values(socket.assigns.selected_versions),
          query: Ash.Query.limit(AshHq.Docs.Option, 10),
          load: [:extension_type]
        )
        |> Enum.concat(docs)
        |> Enum.sort_by(&(-&1.match_rank))

      results =
        search_results
        |> Enum.group_by(& &1.extension_type)
        |> Enum.sort_by(fn {_type, items} ->
          items
          |> Enum.map(& &1.match_rank)
          |> Enum.max()
          |> Kernel.*(-1)
        end)
        |> Enum.map(fn {type, items} ->
          {type, group_by_paths(items)}
        end)

      selected_item =
        case Enum.at(search_results, 0) do
          nil ->
            nil

          item ->
            item.id
        end

      id_list = id_list(results)

      socket
      |> assign(:results, results)
      |> assign(:id_list, id_list)
      |> set_selected_item(selected_item)
    end
  end

  defp id_list(results) do
    List.flatten(do_id_list(results))
  end

  defp do_id_list({_key, %{items: items, further: further}}) do
    do_id_list(items) ++ do_id_list(further)
  end

  defp do_id_list(items) when is_list(items) do
    Enum.map(items, &do_id_list/1)
  end

  defp do_id_list(%{id: id}), do: id

  defp set_selected_item(socket, nil), do: socket

  defp set_selected_item(socket, selected_item) do
    socket
    |> assign(:selected_item, selected_item)
    |> push_event("js:scroll-to", %{id: selected_item})
  end

  defp group_by_paths(items) do
    items
    |> Enum.map(&{&1.path, &1})
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
