defmodule AshHqWeb.Components.Search do
  use Surface.LiveComponent

  require Ash.Query

  alias AshHqWeb.Routes
  alias Surface.Components.{Form, LiveRedirect}
  alias Surface.Components.Form.{Checkbox, Label, Select}

  prop open, :boolean, default: false
  prop close, :event, required: true
  prop libraries, :list, required: true
  prop selected_versions, :map, required: true
  prop change_versions, :event, required: true
  prop selected_types, :list, required: true
  prop change_types, :event, required: true
  prop uri, :string, required: true

  data versions, :map, default: %{}
  data search, :string, default: ""
  data results, :map, default: %{}
  data selected_item, :string

  def render(assigns) do
    ~F"""
    <div
      id={@id}
      style="display: none;"
      class="absolute flex justify-center align-middle w-screen h-full backdrop-blur-sm pb-8 bg-white bg-opacity-10"
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
              <Form for={:search} change="search" submit="go-to-doc" class="w-full">
                <input
                  id="search-input"
                  name="search"
                  class="text-lg dark:bg-primary-black grow ring-0 outline-none w-full"
                />
              </Form>
              <button id="close-search" class="mr-4 ml-4 h-6 w-6 hover:text-gray-400" :on-click={@close}>
                <Heroicons.Outline.XIcon class="h-6 w-6" />
              </button>
            </div>
          </div>
          <div class="grid grid-cols-9 h-[85%] mt-3">
            <div class="col-span-3 md:col-span-2 xl:col-span-1 border-r border-gray-600">
              <Form for={:types} change={@change_types}>
                <div class="flex flex-col border-b">
                  <div>Search for:</div>
                  {#for type <- AshHq.Docs.Extensions.Search.Types.types()}
                    <div class="flex flex-row items-center">
                      <Checkbox class="mr-4" id={"#{type}-selected"} value={type in @selected_types} name={"types[#{type}]"} />
                      <Label field={type}>
                        {type}
                      </Label>
                    </div>
                  {/for}
                </div>
              </Form>
              <Form for={:versions} change={@change_versions}>
                <div class="flex flex-col space-y-2">
                Project versions:
                {#for library <- @libraries}
                  <div class="flex flex-col">
                    <Label field={library.id}>
                      {library.display_name}
                    </Label>
                    <div class="pb-2">
                      <Select
                        id={"versions-select-#{library.id}"}
                        class="text-black form-select rounded-md pt-1 py-2 w-3/4 border dark:border-0 bg-gray-100 dark:bg-white"
                        name={"versions[#{library.id}]"}
                        selected={Map.get(@selected_versions, library.id)}
                        options={[{"latest", "latest"}] ++ Enum.map(library.versions, &{&1.version, &1.id})}
                      />
                    </div>
                  </div>
                {/for}
                </div>
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
        <LiveRedirect to={Routes.doc_link(item, @selected_versions)} opts={id: item.id}>
          <div class={
            "rounded-lg mb-4 py-4 px-2 hover:bg-gray-400 dark:hover:bg-gray-600",
            "bg-gray-400 dark:bg-gray-600": @selected_item.id == item.id,
            "bg-gray-200 dark:bg-gray-800": @selected_item.id != item.id
          }>
            {#if item.__struct__ != AshHq.Docs.LibraryVersion &&
                item.name != List.last(Map.get(results, :path, []))}
              {item.name}
            {/if}
            {#if item.__struct__ == AshHq.Docs.LibraryVersion}
              {item.version}
            {/if}
            <div class="text-gray-700 dark:text-gray-400">
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

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> search()}
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
        {:noreply, push_redirect(socket, to: Routes.doc_link(item))}
    end
  end

  defp search(socket) do
    if socket.assigns[:search] in [nil, ""] || socket.assigns[:selected_versions] in [nil, %{}] do
      assign(socket, :results, %{})
    else
      versions =
        Enum.map(socket.assigns.selected_versions, fn
          {library_id, "latest"} ->
            Enum.find_value(socket.assigns.libraries, fn library ->
              if library.id == library_id do
                case Enum.find(library.versions, &String.contains?(&1.version, ".")) ||
                       Enum.at(library.versions, 0) do
                  nil ->
                    nil

                  version ->
                    version.id
                end
              end
            end)

          {_, version_id} ->
            version_id
        end)
        |> Enum.reject(&is_nil/1)

      %{results: results, item_list: item_list} =
        AshHq.Docs.Search.run!(
          socket.assigns.search,
          versions
        )

      selected_item = Enum.at(item_list, 0)

      socket
      |> assign(:results, results)
      |> assign(:item_list, item_list)
      |> set_selected_item(selected_item)
    end
  end

  defp set_selected_item(socket, nil), do: socket

  defp set_selected_item(socket, selected_item) do
    socket
    |> assign(:selected_item, selected_item)
    |> push_event("js:scroll-to", %{id: selected_item.id, boundary_id: socket.assigns[:id]})
  end
end
