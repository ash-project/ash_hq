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

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="flex-row h-full dark:bg-dark-grid">
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
                {#if @library && library.id == @library.id}
                  {#for %{default_for_target: false} = extension <- get_extensions(library, @selected_versions)}
                    <li class="ml-3">
                      <LiveRedirect
                        to={Routes.extension_link(library, selected_version_name(library, @selected_versions), extension.name)}
                        class={"flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700", "dark:bg-gray-600": @extension == extension.name}
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
      <div class="grow">
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
    {:ok, assign(socket, assigns) |> assign_library() |> assign_extension()}
  end

  defp assign_extension(socket) do
    assign(socket, :extension, socket.assigns[:params]["extension"])
  end

  def mount(socket) do
    socket =
      AshPhoenix.LiveView.keep_live(socket, :libraries, fn _socket ->
        AshHq.Docs.Library.read!()
      end)

    {:ok, socket}
  end

  defp selected_version_name(library, selected_versions) do
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
      case AshHq.Docs.Library.by_name(socket.assigns.params["library"],
             load: [:versions]
           ) do
        {:ok, library} ->
          socket =
            if socket.assigns[:params]["version"] do
              library_version =
                Enum.find(library.versions, &(&1.version == socket.assigns[:params]["version"]))

              if library_version do
                new_selected_versions =
                  Map.put(socket.assigns.selected_versions, library.id, library_version.id)

                assign(
                  socket,
                  :selected_versions,
                  new_selected_versions
                )
                |> push_event("selected-versions", new_selected_versions)
              else
                socket
              end
            else
              socket
            end

          assign(socket, :library, library)

        _ ->
          assign(socket, :library, nil)
      end
    else
      socket
    end
  end
end
