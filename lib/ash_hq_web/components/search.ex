defmodule AshHqWeb.Components.Search do
  @moduledoc "The search overlay modal"
  use Phoenix.LiveComponent

  require Ash.Query

  alias AshHqWeb.Components.Icon
  alias AshHqWeb.DocRoutes
  import Tails

  attr(:libraries, :list, required: true)
  attr(:selected_types, :list, required: true)
  attr(:uri, :string, required: true)
  attr(:close, :any)

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      style="display: none;"
      class="fixed flex justify-center align-middle w-screen h-full backdrop-blur-sm bg-white bg-opacity-10 z-50"
    >
      <div
        phx-click-away={AshHqWeb.AppViewLive.toggle_search()}
        class="dark:text-white absolute rounded-xl left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 w-3/4 h-3/4 max-w-[1200px] bg-white dark:bg-base-dark-850 border-2 dark:border-base-dark-900"
        phx-target={@myself}
        phx-window-keydown="select-previous"
        phx-key="ArrowUp"
      >
        <div
          id="search-body"
          class="h-full"
          phx-target={@myself}
          phx-window-keydown="select-next"
          phx-key="ArrowDown"
        >
          <div class="p-6 h-full grid gap-6 grid-rows-[max-content_auto_max-content]">
            <button
              id="close-search"
              class="absolute top-6 right-6 h-6 w-6 cursor-pointer z-10 hover:text-base-light-400"
              phx-click={@close}
            >
              <span class="hero-x-mark h-6 w-6" />
            </button>
            <div class="flex flex-col w-full sticky">
              <div class="w-full flex flex-row justify-start top-0">
                <span class="hero-magnifying-glass h-6 w-6 mr-4" />
                <div class="flex flex-row justify-between w-full mr-10 border-b border-base-light-600">
                  <.form
                    for={%{}}
                    as={:search}
                    phx-target={@myself}
                    phx-change="search"
                    phx-submit="go-to-doc"
                    class="w-full"
                  >
                    <input
                      id="search-input"
                      name="search"
                      value={@search}
                      phx-debounce={300}
                      class="text-lg dark:bg-base-dark-850 grow ring-0 outline-none w-full"
                    />
                  </.form>
                </div>
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
    assigns = assign(assigns, items: items)

    ~H"""
    <div class="divide-y">
      <%= for item <- @items do %>
        <%= if item.__struct__ == AshHq.Docs.Guide do %>
          <.link
            class="block w-full text-left border-base-light-300 dark:border-base-dark-600"
            href={DocRoutes.doc_link(item)}
            id="result-#{item.id}"
            phx-click={@close}
          >
            <div class={
              classes([
                "hover:bg-base-light-100 dark:hover:bg-base-dark-750 py-1 w-full",
                "bg-base-light-200 dark:bg-base-dark-700": @selected_item.id == item.id
              ])
            }>
              <div class="flex justify-start items-center space-x-2 pb-2 pl-2">
                <div>
                  <Icon.icon type={item_type(item)} classes="h-4 w-4 flex-none mt-1 mx-1" />
                </div>
                <div class="flex flex-col">
                  <div class="text-primary-light-700 dark:text-primary-dark-300">
                    <span class="text-primary-light-700 dark:text-primary-dark-500">
                      {item.library_name}
                    </span>
                    {item_type(item)}
                  </div>
                  <div class="flex flex-row flex-wrap items-center">
                    <div class="font-bold">
                      {item_name(item)}
                    </div>
                  </div>
                  <div>
                    {first_sentence(item)}
                  </div>
                </div>
              </div>
              <div></div>
            </div>
          </.link>
        <% else %>
          <a
            class="block w-full text-left border-base-light-300 dark:border-base-dark-600"
            href={DocRoutes.doc_link(item)}
            id={"result-#{item.id}"}
            phx-click={@close}
          >
            <div class={
              classes([
                "hover:bg-base-light-100 dark:hover:bg-base-dark-750 py-1 w-full",
                "bg-base-light-200 dark:bg-base-dark-700": @selected_item.id == item.id
              ])
            }>
              <div class="flex justify-start items-center space-x-2 pb-2 pl-2">
                <div>
                  <Icon.icon type={item_type(item)} classes="h-4 w-4 flex-none mt-1 mx-1" />
                </div>
                <div class="flex flex-col">
                  <div class="text-primary-light-700 dark:text-primary-dark-300">
                    <span class="text-primary-light-700 dark:text-primary-dark-500">
                      {item.library_name}
                    </span>
                    {item_type(item)}
                  </div>
                  <div class="flex flex-row flex-wrap items-center">
                    <div class="font-bold">
                      {item_name(item)}
                    </div>
                  </div>
                  <div>
                    {first_sentence(item)}
                  </div>
                </div>
              </div>
              <div></div>
            </div>
          </a>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp first_sentence(%{text: text}), do: first_sentence(text)
  defp first_sentence(%{doc: doc}), do: first_sentence(doc)

  defp first_sentence(doc) do
    first_sentence =
      doc
      |> String.trim()
      |> String.split("<!--- heads-end -->", parts: 2, trim: true)
      |> List.last()
      |> String.trim()
      |> String.split("\n", parts: 3, trim: true)
      |> case do
        ["#" <> _ | rest] -> rest
        other -> other
      end
      |> Enum.at(0)
      |> String.trim()

    if String.starts_with?(first_sentence, "`") do
      ""
    else
      first_sentence
    end
  end

  defp item_name(%AshHq.Docs.Function{call_name: call_name, arity: arity}),
    do: call_name <> "/#{arity}"

  defp item_name(%AshHq.Docs.Option{path: path, name: name}), do: Enum.join(path ++ [name], ".")
  defp item_name(%AshHq.Docs.Dsl{path: path, name: name}), do: Enum.join(path ++ [name], ".")
  defp item_name(%{name: name}), do: name
  defp item_name(%{version: version}), do: version

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
        socket.assigns[:item_list]
        |> Kernel.||([])
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
        socket.assigns[:item_list]
        |> Kernel.||([])
        |> Enum.reverse()
        |> Enum.drop_while(&(&1.id != socket.assigns.selected_item.id))
        |> Enum.at(1)

      {:noreply, set_selected_item(socket, next)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("go-to-doc", _data, socket) do
    case Enum.find(socket.assigns[:item_list] || [], fn item ->
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
      assign(socket, :item_list, [])
    else
      item_list =
        socket.assigns.search
        |> AshHq.Docs.Indexer.search()
        |> Enum.take(50)

      socket
      |> assign(:item_list, item_list)
      |> set_selected_item(Enum.at(item_list, 0))
    end
  end

  defp set_selected_item(socket, nil), do: socket

  defp set_selected_item(socket, selected_item) do
    socket
    |> assign(:selected_item, selected_item)
    |> push_event("js:scroll-to", %{id: "result-#{selected_item.id}"})
  end
end
