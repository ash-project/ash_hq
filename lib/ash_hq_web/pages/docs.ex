defmodule AshHqWeb.Pages.Docs do
  use Surface.LiveComponent

  alias Phoenix.LiveView.JS
  alias AshHqWeb.Components.{CalloutText, DocSidebar, ProgressiveHeading, Tag}
  alias AshHqWeb.Routes

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
  data dsls, :list, default: []

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="grow h-full w-full flex flex-col">
      <div class="lg:hidden flex flex-row justify-start space-x-12 items-center border-b border-t border-gray-600 py-3">
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
                  <span class="text-gray-400">
                    {item}
                  </span>
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
                {/for}
                <span class="dark:text-white">
                <CalloutText>{List.last(path)}</CalloutText>
                </span>
            {/case}
          </div>
        {/if}
      </div>
      <span class="lg:hidden">
        <div
          id="mobile-sidebar-container"
          class="hidden fixed w-min h-full bg-primary-black transition"
        >
          <DocSidebar
            id="mobile-sidebar"
            libraries={@libraries}
            extension={@extension}
            dsls={@dsls}
            guide={@guide}
            library={@library}
            library_version={@library_version}
            selected_versions={@selected_versions}
          />
        </div>
      </span>
      <div class="grow flex flex-row h-full justify-center space-x-12">
        <DocSidebar
          id="sidebar"
          class="hidden lg:block mt-10"
          libraries={@libraries}
          extension={@extension}
          dsls={@dsls}
          guide={@guide}
          library={@library}
          library_version={@library_version}
          selected_versions={@selected_versions}
        />
        <div
          id="docs-window"
          class="grow w-full prose lg:max-w-3xl xl:max-w-5xl dark:prose-invert overflow-y-scroll overflow-x-visible"
          phx-hook="Docs"
        >
          {raw(@docs)}
          {#if !Enum.empty?(@dsls)}
            <h1>Dsl Documentation</h1>
            {render_dsl_docs(assigns, @dsls)}
          {/if}
        </div>
      </div>
    </div>
    """
  end

  defp render_dsl_docs(assigns, dsls, path \\ [], depth \\ nil) do
    count = Enum.count(path)
    depth = depth || count + 4

    ~F"""
    {#for dsl <- Enum.filter(dsls, &(&1.path == path)) |> Enum.sort_by(& &1.order)}
      <div class={"w-full pl-2 border-gray-800 border-l", "ml-2": count > 0}>
        <div id={path_to_name(dsl.path, dsl.name)} class="flex flex-row items-center">
          <a href={"##{path_to_name(dsl.path, dsl.name)}"}><Heroicons.Outline.LinkIcon class="h-4 w-4" /></a>
            {render_path(assigns, dsl.path, dsl.name)}
        </div>
        {render_options(assigns, get_options(dsl, @options), depth)}
        {raw(AshHq.Docs.Extensions.RenderMarkdown.render!(dsl, :doc))}
        {render_dsl_docs(assigns, dsls, path ++ [dsl.name], depth + 1)}
      </div>
    {/for}
    """
  end

  def path_to_name(path, name) do
    Enum.map_join(path ++ [name], "-", &Routes.sanitize_name/1)
  end

  defp render_options(assigns, [], _) do
    ~F"""
    """
  end

  defp render_options(assigns, options, depth) do
    ~F"""
    <div class="ml-2">
      <table>
        {#for option <- options}
          <tr id={path_to_name(option.path, option.name)}>
            <td>
              <div class="flex flex-row items-baseline">
                <a href={"##{path_to_name(option.path, option.name)}"}>
                  <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                </a>
                  <CalloutText>{option.name}</CalloutText>
              </div>
            </td>
            <td>
              {option.type}
            </td>
            <td>
              {render_tags(assigns, option)}
            </td>
            <td>
              {raw(AshHq.Docs.Extensions.RenderMarkdown.render!(option, :doc))}
            </td>
          </tr>
        {/for}
      </table>
    </div>
    """
  end

  defp render_path(assigns, path, name) do
    ~F"""
    <div class="flex flex-row space-x-1 items-center">
     {#for item <- path}
       <span class="text-gray-400">
         {item}</span>
       <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
     {/for}
     <span class="dark:text-white">
      <CalloutText>
        {name}
      </CalloutText>
     </span>
    </div>
    """
  end

  defp render_tags(assigns, option) do
    ~F"""
    {#if option.required}
      <Tag color={:red}>
        Required
      </Tag>
    {/if}
    """
  end

  defp get_options(dsl, options) do
    Enum.filter(options, fn option ->
      List.starts_with?(option.path, dsl.path ++ [dsl.name]) &&
        Enum.count(option.path) - Enum.count(dsl.path) == 1
    end)
  end

  def show_sidebar() do
    %JS{}
    |> JS.toggle(
      to: "#mobile-sidebar-container",
      in: {
        "transition ease-in duration-100",
        "opacity-0",
        "opacity-100"
      },
      out: {
        "transition ease-out duration-75",
        "opacity-100",
        "opacity-0"
      }
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
          docs: AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.extension, :doc),
          doc_path: [socket.assigns.library.name, socket.assigns.extension.name],
          dsls: socket.assigns.extension.dsls,
          options: socket.assigns.extension.options
        )

      socket.assigns.guide ->
        assign(socket,
          docs: AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.guide, :text),
          doc_path: [socket.assigns.library.name, socket.assigns.guide.name],
          dsls: [],
          options: []
        )

      socket.assigns.library_version ->
        assign(socket,
          docs:
            AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.library_version, :doc),
          doc_path: [socket.assigns.library.name],
          dsls: [],
          options: []
        )

      true ->
        assign(socket, docs: "", doc_path: [], dsls: [])
    end
  end

  defp assign_extension(socket) do
    if socket.assigns.library do
      extensions = get_extensions(socket.assigns.library, socket.assigns.selected_versions)

      assign(socket,
        extension:
          Enum.find(extensions, fn extension ->
            Routes.sanitize_name(extension.name) == socket.assigns[:params]["extension"]
          end)
      )
    else
      assign(socket, :extension, nil)
    end
  end

  def mount(socket) do
    {:ok, socket}
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
         socket.assigns.params["library"] != Routes.sanitize_name(socket.assigns.library.name) do
      case Enum.find(
             socket.assigns.libraries,
             &(Routes.sanitize_name(&1.name) == socket.assigns.params["library"])
           ) do
        nil ->
          assign(socket, library: nil, library_version: nil)

        library ->
          socket =
            if socket.assigns[:params]["version"] do
              library_version =
                Enum.find(
                  library.versions,
                  &(Routes.sanitize_name(&1.version) == socket.assigns[:params]["version"])
                )

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
