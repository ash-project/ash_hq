defmodule AshHqWeb.Pages.Docs do
  use Surface.LiveComponent

  alias AshHqWeb.Routes
  alias Surface.Components.LiveRedirect

  prop params, :map, required: true
  prop change_versions, :event, required: true
  prop selected_versions, :map, required: true
  prop libraries, :list, default: []

  data library, :any
  data extension, :any
  data docs, :any
  data library_version, :any
  data guide, :any

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="flex flex-row h-full dark:bg-dark-grid justify-center">
      <aside class="w-64 h-full" aria-label="Sidebar">
        <div class="overflow-y-auto py-4 px-3">
          <ul class="space-y-2">
            {#for library <- @libraries}
              <li>
                <LiveRedirect
                  to={Routes.library_link(library, selected_version_name(library, @selected_versions))}
                  class={"flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700", "dark:bg-gray-600": !@extension && @library && library.id == @library.id}
                >
                  <Heroicons.Outline.CollectionIcon class="w-6 h-6" />
                  <span class="ml-3 mr-2">{library.display_name}</span>
                  <span class="font-light text-gray-500">{selected_version_name(library, @selected_versions)}</span>
                </LiveRedirect>
                {#if @library && @library_version && library.id == @library.id}
                  {#if !Enum.empty?(@library_version.guides)}
                    <div class="ml-2 text-gray-500">
                      Guides
                    </div>
                  {/if}
                  {#for guide <- @library_version.guides}
                    <li class="ml-3">
                      <LiveRedirect
                        to={Routes.guide_link(library, selected_version_name(library, @selected_versions), guide.url_safe_name)}
                        class={"flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700", "dark:bg-gray-600": @guide && @guide.id == guide.id}
                      >
                        <Heroicons.Outline.BookOpenIcon class="h-4 w-4"/>
                        <span class="ml-3 mr-2">{guide.name}</span>
                      </LiveRedirect>
                    </li>
                  {/for}

                  {#if !Enum.empty?(@library_version.guides)}
                    <div class="ml-2 text-gray-500">
                      Extensions
                    </div>
                  {/if}
                  {#for extension <- get_extensions(library, @selected_versions)}
                    <li class="ml-3">
                      <LiveRedirect
                        to={Routes.extension_link(library, selected_version_name(library, @selected_versions), extension.name)}
                        class={"flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700", "dark:bg-gray-600": @extension && @extension.id == extension.id}
                      >
                        {render_icon(assigns, extension.type)}
                        <span class="ml-3 mr-2">{extension.name}</span>
                      </LiveRedirect>
                    </li>

                  {/for}
                {/if}
              </li>
            {/for}
          </ul>
        </div>
      </aside>
      <div class="grow w-full prose prose-zinc md:prose-lg lg:prose-xl dark:prose-invert">
        {raw(@docs)}
      </div>
    </div>
    """
  end

  def render_icon(assigns, "Resource") do
    ~F"""
    <Heroicons.Outline.ServerIcon class="h-4 w-4"/>
    """
  end

  def render_icon(assigns, "Api") do
    ~F"""
    <Heroicons.Outline.SwitchHorizontalIcon class="h-4 w-4"/>
    """
  end

  def render_icon(assigns, "DataLayer") do
    ~F"""
    <Heroicons.Outline.DatabaseIcon class="h-4 w-4"/>
    """
  end

  def render_icon(assigns, "Flow") do
    ~F"""
    <Heroicons.Outline.MapIcon class="h-4 w-4"/>
    """
  end

  def render_icon(assigns, "Notifier") do
    ~F"""
    <Heroicons.Outline.MailIcon class="h-4 w-4"/>
    """
  end

  def render_icon(assigns, "Registry") do
    ~F"""
    <Heroicons.Outline.ViewListIcon class="h-4 w-4"/>
    """
  end

  def render_icon(assigns, _) do
    ~F"""
    <Heroicons.Outline.PuzzleIcon class="h-4 w-4"/>
    """
  end

  def update(assigns, socket) do
    {:ok,
     assign(socket, assigns)
     |> assign_library()
     |> assign_extension()
     |> assign_guide()
     |> assign_docs()}
  end

  defp selected_version_name(library, selected_versions) do
    case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
      nil ->
        nil

      version ->
        version.version
    end
  end

  defp assign_guide(socket) do
    guide =
      if socket.assigns[:params]["guide"] && socket.assigns.library_version do
        Enum.find(socket.assigns.library_version.guides, fn guide ->
          guide.url_safe_name == socket.assigns[:params]["guide"]
        end)
      end

    assign(socket, :guide, guide)
  end

  defp assign_docs(socket) do
    cond do
      socket.assigns.extension ->
        assign(socket, :docs, Earmark.as_html!(socket.assigns.extension.doc))

      socket.assigns.guide ->
        assign(socket, :docs, Earmark.as_html!(socket.assigns.guide.text))

      socket.assigns.library_version ->
        assign(socket, :docs, Earmark.as_html!(socket.assigns.library_version.doc))

      true ->
        assign(socket, :docs, "")
    end
  end

  defp assign_extension(socket) do
    if socket.assigns.library do
      extensions = get_extensions(socket.assigns.library, socket.assigns.selected_versions)

      assign(socket,
        extension:
          Enum.find(extensions, fn extension ->
            extension.name == socket.assigns[:params]["extension"]
          end)
      )
    else
      assign(socket, :extension, nil)
    end
  end

  def mount(socket) do
    {:ok, socket}
  end

  defp selected_version(library, selected_versions) do
    case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
      nil ->
        nil

      version ->
        version.version
    end
  end

  defp get_extensions(library, selected_versions) do
    case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
      nil ->
        []

      version ->
        version.extensions
    end
  end

  # defp render_sub_item_nav(assigns, library, path \\ []) do
  #   ~F"""
  #   <ul class="space-y-2">
  #     {#for %{path: ^path, name: name} = dsl <- library.dsls}
  #       <li class="ml-2">
  #         <LiveRedirect
  #           to={Routes.doc_link(dsl)}
  #           class="flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700"
  #         >
  #           <Heroicons.Outline.CollectionIcon class="w-6 h-6" />
  #           <span class="ml-3 mr-2">{library.display_name}</span>
  #           <span class="font-light text-gray-500">{selected_version_name(library, @selected_versions)}</span>
  #         </LiveRedirect>
  #       </li>
  #     {/for}
  #   </ul>
  #   """
  # end

  defp assign_library(socket) do
    if !socket.assigns[:library] ||
         socket.assigns.params["library"] != socket.assigns.library.name do
      case Enum.find(socket.assigns.libraries, &(&1.name == socket.assigns.params["library"])) do
        nil ->
          assign(socket, library: nil, library_version: nil)

        library ->
          socket =
            if socket.assigns[:params]["version"] do
              library_version =
                Enum.find(library.versions, &(&1.version == socket.assigns[:params]["version"]))

              if library_version do
                new_selected_versions =
                  Map.put(socket.assigns.selected_versions, library.id, library_version.id)

                assign(
                  socket,
                  selected_versions: new_selected_versions,
                  library_version: library_version
                )
                |> push_event("selected-versions", new_selected_versions)
              else
                assign(socket, :library_version, nil)
              end
            else
              assign(socket, :library_version, nil)
            end

          assign(socket, :library, library)
      end
    else
      socket
    end
  end
end
