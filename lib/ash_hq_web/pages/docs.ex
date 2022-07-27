defmodule AshHqWeb.Pages.Docs do
  use Surface.LiveComponent

  alias Phoenix.LiveView.JS
  alias AshHqWeb.Components.{CalloutText, DocSidebar, RightNav, Tag}
  alias AshHqWeb.Routes
  require Logger

  prop(params, :map, required: true)
  prop(change_versions, :event, required: true)
  prop(selected_versions, :map, required: true)
  prop(libraries, :list, default: [])
  prop(uri, :string)
  prop(sidebar_state, :map, required: true)
  prop(collapse_sidebar, :event, required: true)
  prop(expand_sidebar, :event, required: true)

  data(library, :any)
  data(extension, :any)
  data(docs, :any)
  data(library_version, :any)
  data(guide, :any)
  data(doc_path, :list, default: [])
  data(dsls, :list, default: [])
  data(dsl, :any)
  data(options, :list, default: [])
  data(module, :any)

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
      <div class="grow w-full overflow-hidden flex flex-row h-full justify-center space-x-12 bg-white dark:bg-primary-black">
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
          class="w-full prose prose-xl max-w-6xl dark:bg-primary-black dark:prose-invert overflow-y-auto overflow-x-visible pr-8 mt-14"
          phx-hook="Docs"
        >
          <div id="module-docs" class="w-full nav-anchor text-black dark:text-white">
            {#if @module}
              <h2>{@module.name}{render_source_code_link(assigns, @module, @library, @library_version)}</h2>
            {/if}
            {raw(render_replacements(assigns, @docs))}
            {#if @dsl}
              {#for {category, links} <- @dsl.links || %{}}
                <h3>{String.capitalize(category)}</h3>
                <ul>
                  {#for link <- links}
                    <li>
                      {raw(render_links("{{link:#{link}}}", assigns))}
                    </li>
                  {/for}
                </ul>
              {/for}
            {/if}
          </div>
          {#if @module}
            {render_functions(assigns, @module.functions, :callback, "Callbacks")}
            {render_functions(assigns, @module.functions, :function, "Functions")}
            {render_functions(assigns, @module.functions, :macro, "Macros")}
          {/if}
          {#case modules_in_scope(@dsl, @extension, @libraries, @selected_versions)}
            {#match []}
            {#match imports}
              <h3>Imported Modules</h3>
              {#for mod <- imports}
                <ul>
                  <li>
                    <a href={Routes.doc_link(mod, @selected_versions)}>{mod.name}</a>
                  </li>
                </ul>
              {/for}
          {/case}
          {#case child_dsls(@extension, @dsl)}
            {#match []}
            {#match children}
              <h3>
                Nested DSLs
              </h3>
              <ul>
                {#for child <- children}
                  <li>
                    <a href={Routes.doc_link(child, @selected_versions)}>{child.name}</a>
                  </li>
                {/for}
              </ul>
          {/case}
          <div class="ml-2">
            <table>
              {#if !Enum.empty?(@options)}
                {#if Enum.any?(@options, & &1.argument_index)}
                  <td colspan="100%">
                    <h3>
                      Arguments
                    </h3>
                  </td>
                  <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Doc</th>
                    <th>Links</th>
                  </tr>
                  {#for option <- positional_options(@options)}
                    <tr id={Routes.sanitize_name(option.name)}>
                      <td>
                        <div class="flex flex-row items-baseline">
                          <a href={"##{Routes.sanitize_name(option.name)}"}>
                            <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                          </a>
                          <div class="flex flex-row space-x-2">
                            <CalloutText>{option.name}</CalloutText>
                            {render_tags(assigns, option)}
                          </div>
                        </div>
                      </td>
                      <td>
                        {option.type}
                      </td>
                      <td>
                        {raw(render_replacements(assigns, AshHq.Docs.Extensions.RenderMarkdown.render!(option, :doc)))}
                      </td>
                      <td>
                        {raw(
                          Enum.map_join(
                            List.flatten(Map.values(option.links || %{})),
                            ", ",
                            &render_links("{{link:#{&1}}}", assigns)
                          )
                        )}
                      </td>
                    </tr>
                  {/for}
                {/if}
                <tr>
                  <td colspan="100%">
                    <h3>
                      Options
                    </h3>
                  </td>
                </tr>
                <tr>
                  <th>Name</th>
                  <th>Type</th>
                  <th>Doc</th>
                  <th>Links</th>
                </tr>
                {#for %{argument_index: nil} = option <- @options}
                  <tr id={Routes.sanitize_name(option.name)}>
                    <td>
                      <div class="flex flex-row items-baseline">
                        <a href={"##{Routes.sanitize_name(option.name)}"}>
                          <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                        </a>
                        <CalloutText>{option.name}</CalloutText>
                        {render_tags(assigns, option)}
                      </div>
                    </td>
                    <td>
                      {option.type}
                    </td>
                    <td>
                      {raw(render_replacements(assigns, AshHq.Docs.Extensions.RenderMarkdown.render!(option, :doc)))}
                    </td>
                    <td>
                      {raw(
                        Enum.map_join(
                          List.flatten(Map.values(option.links || %{})),
                          ", ",
                          &render_links("{{link:#{&1}}}", assigns)
                        )
                      )}
                    </td>
                  </tr>
                {/for}
              {/if}
            </table>
          </div>
        </div>
        {#if @module}
          <div class="w-min overflow-y-auto overflow-x-visible mt-14 dark:bg-primary-black bg-opacity-70">
            <RightNav functions={@module.functions} module={@module.name} />
          </div>
        {#else}
          <div />
        {/if}
      </div>
    </div>
    """
  end

  defp render_source_code_link(assigns, module_or_function, library, library_version) do
    ~F"""
    {#if module_or_function.file}
      <a target="_blank" href={source_link(module_or_function, library, library_version)}>{"</>"}</a>
    {/if}
    """
  end

  defp modules_in_scope(nil, _, _, _), do: []
  defp modules_in_scope(_, nil, _, _), do: []

  defp modules_in_scope(dsl, %{dsls: dsls}, libraries, selected_versions) do
    dsl_path = dsl.path ++ [dsl.name]

    dsls
    |> Enum.filter(fn potential_parent ->
      List.starts_with?(dsl_path, potential_parent.path ++ [potential_parent.name])
    end)
    |> Enum.flat_map(fn dsl ->
      dsl.imports || []
    end)
    |> Enum.flat_map(fn mod_name ->
      case Enum.find_value(libraries, fn library ->
             Enum.find_value(library.versions, fn version ->
               if version.id == selected_versions[library.id] do
                 Enum.find(version.modules, &(&1.name == mod_name))
               end
             end)
           end) do
        nil ->
          Logger.warn("No such module found called #{inspect(mod_name)}")
          []

        module ->
          [module]
      end
    end)
  end

  defp child_dsls(_, nil), do: []
  defp child_dsls(nil, _), do: []

  defp child_dsls(%{dsls: dsls}, dsl) do
    dsl_path = dsl.path ++ [dsl.name]
    dsl_path_count = Enum.count(dsl_path)

    Enum.filter(dsls, fn potential_child ->
      potential_child_path = potential_child.path ++ [potential_child.name]

      List.starts_with?(potential_child_path, dsl_path) &&
        Enum.count(potential_child_path) - dsl_path_count == 1
    end)
  end

  defp positional_options(options) do
    options
    |> Enum.filter(& &1.argument_index)
    |> Enum.sort_by(& &1.argument_index)
  end

  defp render_functions(assigns, functions, type, header) do
    ~F"""
    {#case Enum.filter(functions, &(&1.type == type))}
      {#match []}
      {#match functions}
        <h1>{header}</h1>
        {#for function <- functions}
          <div class="rounded-lg bg-slate-700 bg-opacity-50 px-2">
            <p class="">
              <div class="">
                <div class="flex flex-row items-baseline">
                  <a href={"##{type}-#{Routes.sanitize_name(function.name)}-#{function.arity}"}>
                    <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                  </a>
                  <div
                    class="nav-anchor text-xl font-semibold mb-2"
                    id={"#{type}-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
                  >{function.name}/{function.arity} {render_source_code_link(assigns, function, @library, @library_version)}</div>
                </div>
              </div>
              {#for head <- function.heads}
                <code class="makeup elixir">{head}</code>
              {/for}
              {raw(render_replacements(assigns, AshHq.Docs.Extensions.RenderMarkdown.render!(function, :doc)))}
            </p>
          </div>
        {/for}
    {/case}
    """
  end

  defp source_link(%AshHq.Docs.Module{file: file}, library, library_version) do
    "https://github.com/ash-project/#{library.name}/tree/#{library_version.version}/#{file}"
  end

  defp source_link(%AshHq.Docs.Function{file: file, line: line}, library, library_version) do
    if line do
      "https://github.com/ash-project/#{library.name}/tree/#{library_version.version}/#{file}#L#{line}"
    else
      "https://github.com/ash-project/#{library.name}/tree/#{library_version.version}/#{file}"
    end
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
      cond do
        socket.assigns[:params]["guide"] && socket.assigns.library_version ->
          Enum.find(socket.assigns.library_version.guides, fn guide ->
            guide.route == Enum.join(socket.assigns[:params]["guide"], "/")
          end)

        socket.assigns.library_version && socket.assigns.library_version.default_guide &&
          !socket.assigns[:params]["dsl_path"] && !socket.assigns[:params]["module"] &&
            !socket.assigns[:params]["extension"] ->
          Enum.find(socket.assigns.library_version.guides, fn guide ->
            guide.name == socket.assigns.library_version.default_guide
          end)

        true ->
          nil
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

      true ->
        assign(socket, docs: "", doc_path: [], dsls: [])
    end
  end

  defp render_replacements(assigns, docs) do
    docs
    |> render_links(assigns)
    |> render_mix_deps(assigns)
  end

  defp render_mix_deps(docs, assigns) do
    String.replace(docs, ~r/^(?!\<\/code\>){{mix_dep:.*}}/, fn text ->
      try do
        "{{mix_dep:" <> library = String.trim_trailing(text, "}}")
        render_mix_dep(assigns, library, text)
      rescue
        e ->
          Logger.error("Invalid link #{inspect(e)}")
          text
      end
    end)
  end

  defp render_mix_dep(assigns, library, source) do
    library =
      Enum.find(assigns[:libraries], &(&1.name == library)) ||
        raise "No such library in link: #{source}"

    selected_versions = assigns[:selected_versions]

    version =
      if selected_versions[library.id] == "latest" do
        Enum.find(library.versions, &String.contains?(&1.version, ".")) ||
          AshHqWeb.Helpers.latest_version(library)
      else
        case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
          nil ->
            nil

          version ->
            version
        end
      end

    if String.contains?(version, ".") do
      case String.split(version, ".") do
        [major, minor, "0"] ->
          ~s({:#{library.name}, "~> #{major}.#{minor}"})

        _ ->
          ~s({:#{library.name}, "~> #{version}"})
      end
    else
      ~s({:#{library.name}, github: "ash-project/#{library.name}", branch: "#{version}"})
    end
  end

  defp render_links(docs, assigns) do
    String.replace(docs, ~r/(?!<code>){{link:.*}}(?!<\/code>)/, fn text ->
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
      if selected_versions[library.id] in ["latest", nil, ""] do
        Enum.find(library.versions, &String.contains?(&1.version, ".")) ||
          AshHqWeb.Helpers.latest_version(library)
      else
        case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
          nil ->
            nil

          version ->
            version
        end
      end

    if is_nil(version) do
      raise "no version for library"
    else
      case type do
        "guide" ->
          guide =
            Enum.find(version.guides, &(&1.name == item)) ||
              raise "No such guide in link: #{source}"

          """
          <a href="#{Routes.doc_link(guide, assigns[:selected_versions])}">#{item}</a>
          """

        "dsl" ->
          name =
            item
            |> String.split("/")
            |> Enum.join(".")

          """
          <a href="/docs/dsl/#{Routes.sanitize_name(library.name)}/#{Routes.sanitize_name(version.version)}/#{item}">#{name}</a>
          """

        "module" ->
          """
          <a href="/docs/module/#{Routes.sanitize_name(library.name)}/#{Routes.sanitize_name(version.version)}/#{Routes.sanitize_name(item)}">#{item}</a>
          """

        "extension" ->
          """
          <a href="/docs/dsl/#{Routes.sanitize_name(library.name)}/#{Routes.sanitize_name(version.version)}/#{Routes.sanitize_name(item)}">#{item}</a>
          """

        type ->
          raise "unimplemented link type #{inspect(type)} in #{source}"
      end
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
                    AshHqWeb.Helpers.latest_version(library)

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
