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

  # style={"display: none;"}

  def render(assigns) do
    ~F"""
    <div id={@id} class="transition absolute flex justify-center align-middle w-screen h-screen backdrop-blur-sm pb-8 bg-white bg-opacity-10" phx-hook="CmdK">
      <div
        :on-click-away={AshHqWeb.AppViewLive.toggle_search()}
        class="dark:text-white absolute rounded-xl left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 w-1/2 h-3/4 bg-white dark:bg-primary-black border-2 dark:border-gray-900"
        >
        <div class="h-full px-6 my-6">
          <div class="w-full flex flex-row justify-start sticky top-0 pb-3 border-b border-gray-600">
            <Heroicons.Outline.SearchIcon class="h-6 w-6 mr-4 ml-4" />
            <div class="flex flex-row justify-between w-full">
              <Form for={:search} change="search" class="w-full">
                <input id="search-input" name="search" class="text-lg bg-primary-black grow ring-0 outline-none w-full" />
              </Form>
              <button id="close-search" class="mr-4 ml-4 h-6 w-6 hover:text-gray-400" :on-click={@close}>
                <Heroicons.Outline.XIcon class="h-6 w-6" />
              </button>
            </div>
          </div>
          <div class="grid grid-cols-6 h-[82%] mt-3">
            <div class="border-r border-gray-600">
              <Form for={:versions} change="change_versions">
                {#for library <- @libraries}
                  <Label field={library.id}>
                    {library.name}
                  </Label>
                  <div>
                    <Select class="text-black" name={"versions[#{library.id}]"} options={Enum.map(library.versions, &{&1.version, &1.id})} />
                  </div>
                {/for}
              </Form>
            </div>
            <div class="col-span-5 pl-4 overflow-y-auto">
               {render_results(assigns, @results)}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_results(assigns, results) do
    ~F"""
    {#for {group, result} <- @results}
      <div>
        {group}
      </div>
    {/for}
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

      results =
        AshHq.Docs.Option.search!(
          socket.assigns.search,
          Map.values(socket.assigns.selected_versions),
          query: Ash.Query.limit(AshHq.Docs.Option, 10),
          load: [:extension_type]
        )
        |> Enum.concat(docs)
        |> tap(fn items ->
          Enum.map(items, & &1.match_rank) |> IO.inspect()
        end)
        |> Enum.group_by(& &1.extension_type)
        |> Enum.sort_by(fn {_type, items} ->
          items
          |> Enum.map(& &1.match_rank)
          |> Enum.max()
          |> Kernel.*(-1)
        end)
        |> tap(fn stuff ->
          stuff
          |> Enum.map(fn {_type, items} ->
            items
            |> Enum.map(& &1.match_rank)
            |> Enum.max()

            # |> Kernel.*(-1)
          end)
          |> IO.inspect()
        end)
        |> Enum.map(fn {type, items} ->
          {type, group_by_paths(items)}
        end)

      assign(socket, :results, results)
    end
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

    %{path: path_acc, items: items_for_group, further: further_items}
  end
end
