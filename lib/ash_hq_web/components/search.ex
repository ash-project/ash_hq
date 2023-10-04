defmodule AshHqWeb.Components.Search do
  @moduledoc "The search overlay modal"
  use Surface.LiveComponent

  require Ash.Query

  alias AshHqWeb.Components.Icon
  alias AshHqWeb.DocRoutes
  alias Surface.Components.{Form, LivePatch}
  alias Surface.Components.Form.Checkbox

  prop(close, :event, required: true)
  prop(libraries, :list, required: true)
  prop(selected_types, :list, required: true)
  prop(change_types, :event, required: true)
  prop(change_versions, :event, required: true)
  prop(remove_version, :event, required: true)
  prop(uri, :string, required: true)

  data(search, :string, default: "")
  data(item_list, :list, default: [])
  data(selected_item, :string)
  data(selecting_packages, :boolean, default: false)

  def render(assigns) do
    ~F"""
    <div
      id={@id}
      style="display: none;"
      class="fixed flex justify-center align-middle w-screen h-full backdrop-blur-sm bg-white bg-opacity-10 z-50"
    >
      <div
        :on-click-away={AshHqWeb.AppViewLive.toggle_search()}
        class="dark:text-white absolute rounded-xl left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 w-3/4 h-3/4 max-w-[1200px] bg-white dark:bg-base-dark-850 border-2 dark:border-base-dark-900"
        :on-window-keydown="select-previous"
        phx-key="ArrowUp"
      >
        <div id="search-body" class="h-full" :on-window-keydown="select-next" phx-key="ArrowDown">
          <div class="p-6 h-full grid gap-6 grid-rows-[max-content_auto_max-content]">
            <button
              id="close-search"
              class="absolute top-6 right-6 h-6 w-6 cursor-pointer z-10 hover:text-base-light-400"
              :on-click={@close}
            >
              <Heroicons.Outline.XIcon class="h-6 w-6" />
            </button>
            <div class="flex flex-col w-full sticky">
              <div class="w-full flex flex-row justify-start top-0">
                <Heroicons.Outline.SearchIcon class="h-6 w-6 mr-4" />
                <div class="flex flex-row justify-between w-full mr-10 border-b border-base-light-600">
                  <Form for={%{}} as={:sign_out} change="search" submit="go-to-doc" class="w-full">
                    <input
                      id="search-input"
                      name="search"
                      value={@search}
                      phx-debounce={300}
                      class="text-lg dark:bg-base-dark-850 grow ring-0 outline-none w-full"
                    />
                  </Form>
                </div>
              </div>
              <div class="ml-10">
                <Form for={%{}} as={:types} change={@change_types}>
                  <div class="sm:grid sm:grid-cols-2 md:grid-cols-3 lg:flex lg:flex-row lg:space-x-6 lg:flex-wrap mt-2 text-sm text-base-light-500 dark:text-base-dark-300">
                    <div class="hidden lg:block">Search For:</div>
                    {#for type <- AshHq.Docs.Extensions.Search.Types.types() -- ["Forum"]}
                      <div class="flex flex-row items-center">
                        <Checkbox
                          class="mr-2"
                          id={"#{type}-selected"}
                          value={type in @selected_types}
                          name={"types[#{type}]"}
                        />
                        <label for={"#{type}-selected"}>
                          <Icon type={type} classes="h-5 w-5 flex-none -mt-0.5 inline-block" />
                          {type}
                        </label>
                      </div>
                    {/for}
                  </div>
                </Form>
              </div>
            </div>
            <div class="grid overflow-auto scroll-parent">
              {render_items(assigns, @item_list)}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_items(assigns, items) do
    ~F"""
    <div class="divide-y">
      {#for item <- items}
        {#if item.__struct__ != AshHq.Docs.Guide}
          <a
            class="block w-full text-left border-base-light-300 dark:border-base-dark-600"
            href={DocRoutes.doc_link(item)}
            id={"result-#{item.id}"}
            phx-click={@close}
          >
            <div class={
              "hover:bg-base-light-100 dark:hover:bg-base-dark-750 py-4",
              "bg-base-light-200 dark:bg-base-dark-700": @selected_item.id == item.id
            }>
              <div class="flex justify-start items-center space-x-2 pb-2 pl-2">
                <div>
                  <Icon type={item_type(item)} classes="h-4 w-4 flex-none mt-1 mx-1" />
                </div>
                <div class="flex flex-row flex-wrap items-center">
                  {#for {path_item, index} <- Enum.with_index(item_path(item))}
                    {#if index != 0}
                      <Heroicons.Solid.ChevronRightIcon class="h-4 w-4 mt-1" />
                    {/if}
                    <div>
                      {path_item}
                    </div>
                  {/for}
                  <Heroicons.Solid.ChevronRightIcon class="h-4 w-4 mt-1" />
                  <div class="font-bold">
                    {item_name(item)}
                  </div>
                </div>
              </div>
              <div class="text-base-light-700 dark:text-base-dark-400 ml-10">
                {raw(item.search_headline)}
              </div>
            </div>
          </a>
        {/if}
        {#if item.__struct__ == AshHq.Docs.Guide}
          <LivePatch
            class="block w-full text-left border-base-light-300 dark:border-base-dark-600"
            to={DocRoutes.doc_link(item)}
            opts={id: "result-#{item.id}", "phx-click": @close}
          >
            <div class={
              "hover:bg-base-light-100 dark:hover:bg-base-dark-750 py-4",
              "bg-base-light-200 dark:bg-base-dark-700": @selected_item.id == item.id
            }>
              <div class="flex justify-start items-center space-x-2 pb-2 pl-2">
                <div>
                  <Icon type={item_type(item)} classes="h-4 w-4 flex-none mt-1 mx-1" />
                </div>
                <div class="flex flex-row flex-wrap items-center">
                  {#for {path_item, index} <- Enum.with_index(item_path(item))}
                    {#if index != 0}
                      <Heroicons.Solid.ChevronRightIcon class="h-4 w-4 mt-1" />
                    {/if}
                    <div>
                      {path_item}
                    </div>
                  {/for}
                  <Heroicons.Solid.ChevronRightIcon class="h-4 w-4 mt-1" />
                  <div class="font-bold">
                    {item_name(item)}
                  </div>
                </div>
              </div>
              <div class="text-base-light-700 dark:text-base-dark-400 ml-10">
                {raw(item.search_headline)}
              </div>
            </div>
          </LivePatch>
        {/if}
      {/for}
    </div>
    """
  end

  defp item_name(%{thread_name: thread_name, channel_name: channel_name}),
    do: "#{String.capitalize(channel_name)} Forum: #{inspect(thread_name)}"

  defp item_name(%{name: name}), do: name
  defp item_name(%{version: version}), do: version

  defp item_path(%{
         library_name: library_name,
         extension_name: extension_name,
         path: path
       }) do
    [library_name, extension_name, path] |> List.flatten()
  end

  defp item_path(%{
         library_name: library_name,
         module_name: module_name
       }) do
    [library_name, module_name]
  end

  defp item_path(%{library_name: library_name}) do
    [library_name]
  end

  defp item_path(%{library_version: %{library_name: library_name}}) do
    [library_name]
  end

  defp item_path(_) do
    []
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    if assigns[:uri] != socket.assigns[:uri] do
      {:ok, socket |> assign(:search, nil) |> assign(assigns) |> search()}
    else
      {:ok, socket |> assign(assigns) |> search()}
    end
  end

  def handle_event("toggle_versions", _, socket) do
    {:noreply, socket |> assign(:selecting_packages, !socket.assigns.selecting_packages)}
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

  def handle_event("go-to-doc", _data, socket) do
    case Enum.find(socket.assigns.item_list, fn item ->
           item.id == socket.assigns.selected_item.id
         end) do
      nil ->
        {:noreply, socket}

      item ->
        {:noreply,
         socket
         |> push_event("click-on-item", %{"id" => "result-#{item.id}"})}
    end
  end

  defp item_type(%resource{}) do
    AshHq.Docs.Extensions.Search.item_type(resource)
  end

  defp search(socket) do
    if socket.assigns.search in [nil, ""] do
      socket
    else
      %{result: item_list} =
        AshHq.Docs.Search.run!(
          socket.assigns.search,
          %{types: socket.assigns[:selected_types]}
        )

      item_list = Enum.take(item_list, 50)

      selected_item = Enum.at(item_list, 0)

      socket
      |> assign(:item_list, item_list)
      |> set_selected_item(selected_item)
    end
  end

  defp set_selected_item(socket, nil), do: socket

  defp set_selected_item(socket, selected_item) do
    socket
    |> assign(:selected_item, selected_item)
    |> push_event("js:scroll-to", %{id: "result-#{selected_item.id}"})
  end
end
