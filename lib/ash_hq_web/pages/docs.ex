defmodule AshHqWeb.Pages.Docs do
  use Surface.LiveComponent

  alias Phoenix.LiveView.JS
  alias AshHqWeb.Components.{CalloutText, DocSidebar, RightNav, Tag}
  alias AshHqWeb.Routes
  require Logger

  prop params, :map, required: true
  prop change_versions, :event, required: true
  prop selected_versions, :map, required: true
  prop libraries, :list, default: []
  prop uri, :string
  prop sidebar_state, :map, required: true
  prop collapse_sidebar, :event, required: true
  prop expand_sidebar, :event, required: true

  data library, :any
  data extension, :any
  data docs, :any
  data library_version, :any
  data guide, :any
  data doc_path, :list, default: []
  data dsls, :list, default: []
  data dsl, :any
  data options, :list, default: []
  data module, :any

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="grid content-start overflow-hidden">
      <div class="xl:hidden flex flex-row justify-start space-x-12 items-center border-b border-t border-gray-600 py-3">
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
      <span class="grid overflow-hidden xl:hidden">
        <div
          id="mobile-sidebar-container"
          class="overflow-hidden hidden fixed w-min h-full transition bg-white dark:bg-primary-black"
        >
          <DocSidebar
            id="mobile-sidebar"
            libraries={@libraries}
            extension={@extension}
            sidebar_state={@sidebar_state}
            collapse_sidebar={@collapse_sidebar}
            expand_sidebar={@expand_sidebar}
            module={@module}
            guide={@guide}
            library={@library}
            library_version={@library_version}
            selected_versions={@selected_versions}
            dsl={@dsl}
          />
        </div>
      </span>
      <div class="grow overflow-hidden flex flex-row h-full justify-center space-x-12 bg-white dark:bg-primary-black">
        <DocSidebar
          id="sidebar"
          class="hidden xl:block mt-10"
          module={@module}
          libraries={@libraries}
          extension={@extension}
          sidebar_state={@sidebar_state}
          collapse_sidebar={@collapse_sidebar}
          expand_sidebar={@expand_sidebar}
          guide={@guide}
          library={@library}
          library_version={@library_version}
          selected_versions={@selected_versions}
          dsl={@dsl}
        />
        <div
          id="docs-window"
          class="w-full prose dark:bg-primary-black md:max-w-1xl lg:max-w-2xl xl:max-w-3xl dark:prose-invert overflow-y-scroll overflow-x-visible mt-14"
          phx-hook="Docs"
        >
          <div id="module-docs" class="w-full nav-anchor text-black dark:text-white">
            {raw(render_links(assigns, @docs))}
          </div>
          {#if @module}
            <h1>Callbacks</h1>
            {render_functions(assigns, @module.functions, :callback)}

            <h1>Functions</h1>
            {render_functions(assigns, @module.functions, :function)}

            <h1>Macros</h1>
            {render_functions(assigns, @module.functions, :macro)}
          {/if}
          {#if !Enum.empty?(@options)}
            <div class="ml-2">
              <table>
                {#for option <- @options}
                  <tr id={Routes.sanitize_name(option.name)}>
                    <td>
                      <div class="flex flex-row items-baseline">
                        <a href={"##{Routes.sanitize_name(option.name)}"}>
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
          {/if}
        </div>
        {#if @module}
          <div class="w-min overflow-y-scroll overflow-x-visible mt-14 dark:bg-primary-black bg-opacity-70">
            <RightNav functions={@module.functions} module={@module.name} />
          </div>
        {/if}
      </div>
    </div>
    """
  end

  defp render_functions(assigns, functions, type) do
    ~F"""
    {#for function <- Enum.filter(functions, &(&1.type == type))}
      <div class="rounded-lg bg-slate-700 bg-opacity-50 px-2 mb-2 pb-1">
        <p class="">
          <div class="">
            <div class="flex flex-row items-baseline h-min">
              <a href={"##{type}-#{Routes.sanitize_name(function.name)}-#{function.arity}"}>
                <Heroicons.Outline.LinkIcon class="h-3 m-3" />
              </a>
              <h2 class="nav-anchor" id={"#{type}-#{Routes.sanitize_name(function.name)}-#{function.arity}"}>{function.name}/{function.arity}</h2>
            </div>
          </div>
          {#for head <- function.heads}
            <code class="makeup elixir">{head}</code>
          {/for}
          {raw(AshHq.Docs.Extensions.RenderMarkdown.render!(function, :doc))}
        </p>
      </div>
    {/for}
    """
  end

  def path_to_name(path, name) do
    Enum.map_join(path ++ [name], "-", &Routes.sanitize_name/1)
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
     socket
     |> assign(assigns)
     |> assign_library()
     |> assign_extension()
     |> assign_guide()
     |> assign_module()
     |> assign_dsl()
     |> assign_docs()}
  end

  defp assign_guide(socket) do
    guide =
      if socket.assigns[:params]["guide"] && socket.assigns.library_version do
        Enum.find(socket.assigns.library_version.guides, fn guide ->
          guide.route == Enum.join(socket.assigns[:params]["guide"], "/")
        end)
      end

    assign(socket, :guide, guide)
  end

  defp assign_dsl(socket) do
    case socket.assigns[:params]["dsl_path"] do
      nil ->
        assign(socket, :dsl, nil)

      path ->
        dsl =
          Enum.find(
            socket.assigns.extension.dsls,
            fn dsl ->
              Enum.map(dsl.path, &Routes.sanitize_name/1) ++ [Routes.sanitize_name(dsl.name)] ==
                path
            end
          )

        new_state = Map.put(socket.assigns.sidebar_state, dsl.id, "open")

        unless socket.assigns.sidebar_state[dsl.id] == "open" do
          send(self(), {:new_sidebar_state, new_state})
        end

        socket
        |> assign(
          :dsl,
          dsl
        )
    end
  end

  defp assign_module(socket) do
    if socket.assigns.library && socket.assigns.library_version &&
         socket.assigns[:params]["module"] do
      module =
        Enum.find(
          socket.assigns.library_version.modules,
          &(Routes.sanitize_name(&1.name) == socket.assigns[:params]["module"])
        )

      assign(socket,
        module: module
      )
    else
      assign(socket, :module, nil)
    end
  end

  defp assign_docs(socket) do
    cond do
      socket.assigns.module ->
        assign(socket,
          docs: AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.module, :doc),
          doc_path: [socket.assigns.library.name, socket.assigns.module.name],
          options: []
        )

      socket.assigns.dsl ->
        assign(socket,
          docs: AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.dsl, :doc),
          doc_path:
            [
              socket.assigns.library.name,
              socket.assigns.extension.name
            ] ++ socket.assigns.dsl.path ++ [socket.assigns.dsl.name],
          options:
            Enum.filter(
              socket.assigns.extension.options,
              &(&1.path == socket.assigns.dsl.path ++ [socket.assigns.dsl.name])
            )
        )

      socket.assigns.extension ->
        assign(socket,
          docs: AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.extension, :doc),
          doc_path: [socket.assigns.library.name, socket.assigns.extension.name],
          options: []
        )

      socket.assigns.guide ->
        assign(socket,
          docs: AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.guide, :text),
          doc_path: [socket.assigns.library.name, socket.assigns.guide.name],
          options: []
        )

      socket.assigns.library_version ->
        assign(socket,
          docs:
            AshHq.Docs.Extensions.RenderMarkdown.render!(socket.assigns.library_version, :doc),
          doc_path: [socket.assigns.library.name],
          options: []
        )

      true ->
        assign(socket, docs: "", doc_path: [], dsls: [])
    end
  end

  defp render_links(assigns, docs) do
    String.replace(docs, ~r/{{link:.*}}/, fn text ->
      try do
        "{{link:" <> rest = String.trim_trailing(text, "}}")
        [library, type, item] = String.split(rest, ":")
        render_link(assigns, library, type, item, text)
      rescue
        e ->
          Logger.error("Invalid link #{inspect(e)}")
          text
      end
    end)
  end

  defp render_link(assigns, library, type, item, source) do
    library =
      Enum.find(assigns[:libraries], &(&1.name == library)) ||
        raise "No such library in link: #{source}"

    selected_versions = assigns[:selected_versions]

    version =
      if selected_versions[library.id] == "latest" do
        "latest"
      else
        case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
          nil ->
            nil

          version ->
            version
        end
      end

    if type == "guide" do
      guide =
        Enum.find(version.guides, &(&1.name == item)) || raise "No such guide in link: #{source}"

      """
      <a href="#{Routes.doc_link(guide, assigns[:selected_versions])}">#{item}</a>
      """
    else
      raise "unimplemented link type #{inspect(type)} in #{source}"
    end
  end

  defp assign_extension(socket) do
    if socket.assigns.library_version && socket.assigns[:params]["extension"] do
      extensions = socket.assigns.library_version.extensions

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
                case socket.assigns[:params]["version"] do
                  "latest" ->
                    Enum.find(library.versions, &String.contains?(&1.version, ".")) ||
                      Enum.at(library.versions, 0)

                  version ->
                    Enum.find(
                      library.versions,
                      &(Routes.sanitize_name(&1.version) == version)
                    )
                end

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
