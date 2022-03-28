defmodule AshHqWeb.Pages.Docs do
  use Surface.LiveComponent

  alias Phoenix.LiveView.JS
  alias AshHqWeb.Components.DocSidebar

  prop params, :map, required: true
  prop change_versions, :event, required: true
  prop selected_versions, :map, required: true
  prop libraries, :list, default: []

  data library, :any
  data extension, :any
  data docs, :any
  data library_version, :any
  data guide, :any
  data doc_path, :list, default: []

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="h-full w-full flex flex-col bg-light-grid dark:bg-dark-grid">
      <div class="md:hidden flex flex-row justify-start space-x-12 mt-2 items-center border-b border-t border-gray-600 py-3 mb-10">
        <button class="dark:hover:text-gray-600" phx-click={show_sidebar()}>
          <Heroicons.Outline.MenuIcon class="w-8 h-8 ml-4" />
        </button>
        {#if @doc_path && @doc_path != []}
          <div class="flex flex-row space-x-1 items-center">
            {#case @doc_path}
              {#match [item]}
                <div class="dark:text-white">
                  {item}
                </div>
              {#match path}
                {#for item <- :lists.droplast(path)}
                  <span class="text-gray-500">
                    {item}</span>
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
                {/for}
                <span class="dark:text-white" />
            {/case}
          </div>
        {/if}
      </div>
      <div id="mobile-sidebar-container" class="hidden md:hidden relative w-screen h-full backdrop-blur-lg transition">
        <div>
        <DocSidebar
          id="mobile-sidebar"
          class="absolute left-0 top-0"
          libraries={@libraries}
          extension={@extension}
          guide={@guide}
          library={@library}
          library_version={@library_version}
          selected_versions={@selected_versions}
        />
        </div>
      </div>
        <div class="grow flex flex-row h-full justify-center space-x-12">
          <DocSidebar
            id="sidebar"
            class="hidden md:block"
            libraries={@libraries}
            extension={@extension}
            guide={@guide}
            library={@library}
            library_version={@library_version}
            selected_versions={@selected_versions}
          />
          <div class="grow w-full prose prose-zinc md:prose-lg lg:prose-xl dark:prose-invert">
            {raw(@docs)}
          </div>
        </div>
    </div>
    """
  end

  def show_sidebar() do
    %JS{}
    |> JS.toggle(
      to: "#mobile-sidebar-container",
      in: {"fade-in duration-100 transition", "hidden", "block"},
      out: {"fade-out duration-100 transition", "block", "hidden"},
      time: 100
    )
  end

  def update(assigns, socket) do
    {:ok,
     assign(socket, assigns)
     |> assign_library()
     |> assign_extension()
     |> assign_guide()
     |> assign_docs()}
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
        assign(socket,
          docs: Earmark.as_html!(socket.assigns.extension.doc),
          doc_path: [socket.assigns.library.name, socket.assigns.extension.name]
        )

      socket.assigns.guide ->
        assign(socket,
          docs: Earmark.as_html!(socket.assigns.guide.text),
          doc_path: [socket.assigns.library.name, socket.assigns.guide.name]
        )

      socket.assigns.library_version ->
        assign(socket,
          docs: Earmark.as_html!(socket.assigns.library_version.doc),
          doc_path: [socket.assigns.library.name]
        )

      true ->
        assign(socket, docs: "", doc_path: [])
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
