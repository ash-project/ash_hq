defmodule AshHqWeb.Pages.Docs do
  @moduledoc "The page for showing documentation"
  use Surface.LiveComponent

  import AshHqWeb.Helpers

  alias AshHqWeb.Components.{CalloutText, DocSidebar, RightNav, Tag}
  alias AshHqWeb.Components.Docs.{DocPath, Functions, SourceLink}
  alias AshHqWeb.DocRoutes
  alias Phoenix.LiveView.JS
  require Logger

  prop change_versions, :event, required: true
  prop selected_versions, :map, required: true
  prop libraries, :list, default: []
  prop uri, :string
  prop remove_version, :event
  prop add_version, :event
  prop change_version, :event
  prop params, :map, required: true

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
  data mix_task, :any
  data positional_options, :list

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="flex flex-col xl:flex-row justify-center overflow-hidden">
      <div class="xl:hidden flex flex-row justify-start w-full space-x-12 items-center border-b border-t border-base-light-600 py-3">
        <button class="dark:hover:text-base-dark-600" phx-click={show_sidebar()}>
          <Heroicons.Outline.MenuIcon class="w-8 h-8 ml-4" />
        </button>
        <button id={"#{@id}-hide"} class="hidden" phx-click={hide_sidebar()} />
        {#if @doc_path && @doc_path != []}
          <DocPath doc_path={@doc_path} />
        {/if}
      </div>
      <span class="grid overflow-hidden xl:hidden z-30">
        <div id="mobile-sidebar-container" class="overflow-hidden hidden fixed w-min transition">
          <DocSidebar
            id="mobile-sidebar"
            remove_version={@remove_version}
            libraries={@libraries}
            extension={@extension}
            module={@module}
            mix_task={@mix_task}
            guide={@guide}
            library={@library}
            library_version={@library_version}
            selected_versions={@selected_versions}
            dsl={@dsl}
          />
        </div>
      </span>
      <div class="grow w-screen overflow-hidden flex flex-row max-w-[1800px] h-full justify-between md:space-x-12 bg-white dark:bg-base-dark-900">
        <div class="xl:border-r lg:pr-2 lg:pt-4">
          <DocSidebar
            id="sidebar"
            class="hidden xl:block w-80 overflow-x-hidden custom-scrollbar"
            remove_version={@remove_version}
            module={@module}
            mix_task={@mix_task}
            libraries={@libraries}
            extension={@extension}
            guide={@guide}
            library={@library}
            library_version={@library_version}
            selected_versions={@selected_versions}
            dsl={@dsl}
          />
        </div>
        <div
          id="docs-window"
          class="scroll-parent w-full prose prose-xl max-w-4xl dark:bg-base-dark-900 dark:prose-invert overflow-y-auto overflow-x-visible md:pr-8 md:mt-4 px-4 md:px-auto custom-scrollbar"
          phx-hook="Docs"
        >
          <div
            id="module-docs"
            class="w-full nav-anchor text-black dark:text-white relative py-4 md:py-auto"
          >
            {#if @module}
              <h2>{@module.name} <SourceLink module_or_function={@module} library={@library} library_version={@library_version} /></h2>
            {/if}
            {#if @mix_task}
              <h2>{@mix_task.name} <SourceLink
                  module_or_function={@mix_task}
                  library={@library}
                  library_version={@library_version}
                /></h2>
            {/if}
            {#if @library_version}
              <div class="static mb-6 md:absolute right-2 top-2 border rounded-lg flex flex-row w-fit">
                <div class="border-r pl-2 pr-2 dark:text-black bg-primary-light-600 dark:bg-primary-dark-600 rounded-l-lg">
                  {@library.name}
                </div>
                <div class="pl-2 pr-2 rounded-r-lg bg-base-light-300 dark:bg-inherit">
                  {@library_version.version}
                </div>
              </div>
            {/if}
            {raw(render_replacements(@libraries, @selected_versions, @docs))}
            {#if @extension && !@dsl && !@guide}
              {#case Enum.count_until(Stream.filter(@extension.dsls, &(&1.type == :section)), 2)}
                {#match 0}
                  <div />
                {#match 1}
                  <h3>
                    DSL
                  </h3>
                {#match 2}
                  <h3>
                    DSL Sections
                  </h3>
              {/case}
              <ul>
                {#for section <- Enum.filter(@extension.dsls, &(&1.type == :section))}
                  <li>
                    <a href={DocRoutes.doc_link(section, @selected_versions)}>{section.name}</a>
                  </li>
                {/for}
              </ul>
            {/if}
            {#if @dsl}
              {#for {category, links} <- @dsl.links || %{}}
                <h3>{String.capitalize(category)}</h3>
                <ul>
                  {#for link <- links}
                    <li>
                      {raw(render_links("{{link:#{link}}}", @libraries, @selected_versions))}
                    </li>
                  {/for}
                </ul>
              {/for}
            {/if}
          </div>
          {#if @module}
            <Functions
              header="Types"
              type={:type}
              functions={@module.functions}
              library={@library}
              library_version={@library_version}
              libraries={@libraries}
              selected_versions={@selected_versions}
            />
            <Functions
              header="Callbacks"
              type={:callback}
              functions={@module.functions}
              library={@library}
              library_version={@library_version}
              libraries={@libraries}
              selected_versions={@selected_versions}
            />
            <Functions
              header="Functions"
              type={:function}
              functions={@module.functions}
              library={@library}
              library_version={@library_version}
              libraries={@libraries}
              selected_versions={@selected_versions}
            />
            <Functions
              header="Macros"
              type={:macro}
              functions={@module.functions}
              library={@library}
              library_version={@library_version}
              libraries={@libraries}
              selected_versions={@selected_versions}
            />
          {/if}
          {#case modules_in_scope(@dsl, @extension, @libraries, @selected_versions)}
            {#match []}
            {#match imports}
              <h3>Imported Modules</h3>
              {#for mod <- imports}
                <ul>
                  <li>
                    <a href={DocRoutes.doc_link(mod, @selected_versions)}>{mod.name}</a>
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
                    <a href={DocRoutes.doc_link(child, @selected_versions)}>{child.name}</a>
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
                    <tr id={"#{option.sanitized_path}/#{option.name}"}>
                      <td>
                        <div class="flex flex-row items-baseline">
                          <a href={"##{DocRoutes.sanitize_name(option.name)}"}>
                            <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                          </a>
                          <div class="flex flex-row space-x-2">
                            <CalloutText text={option.name} />
                            {render_tags(assigns, option)}
                          </div>
                        </div>
                      </td>
                      <td>
                        {option.type}
                      </td>
                      <td>
                        {raw(render_replacements(@libraries, @selected_versions, option.html_for))}
                      </td>
                      <td>
                        {raw(
                          Enum.map_join(
                            List.flatten(Map.values(option.links || %{})),
                            ", ",
                            &render_links("{{link:#{&1}}}", @libraries, @selected_versions)
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
                  <tr id={"#{option.sanitized_path}/#{option.name}"}>
                    <td id={DocRoutes.sanitize_name(option.name)}>
                      <div class="flex flex-row items-baseline">
                        <a href={"##{DocRoutes.sanitize_name(option.name)}"}>
                          <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                        </a>
                        <CalloutText text={option.name} />
                        {render_tags(assigns, option)}
                      </div>
                    </td>
                    <td>
                      {option.type}
                    </td>
                    <td>
                      {raw(render_replacements(@libraries, @selected_versions, option.html_for))}
                    </td>
                    <td>
                      {raw(
                        Enum.map_join(
                          List.flatten(Map.values(option.links || %{})),
                          ", ",
                          &render_links("{{link:#{&1}}}", @libraries, @selected_versions)
                        )
                      )}
                    </td>
                  </tr>
                {/for}
              {/if}
            </table>
          </div>

          <footer class="relative p-2 sm:justify-center">
            <div class="md:flex md:justify-around items-center">
              <a href="/">
                <img class="h-6 md:h-10 hidden dark:block" src="/images/ash-framework-dark.png">
                <img class="h-6 md:h-10 dark:hidden" src="/images/ash-framework-light.png">
              </a>
              <a href="https://github.com/ash-project" class="hover:underline">Source</a>
              <a href="https://github.com/ash-project/ash_hq/issues/new/choose" class="hover:underline">Report an issue</a>
            </div>
          </footer>
        </div>
        {#if @module}
          <div class="lg:w-72 overflow-y-auto overflow-x-hidden dark:bg-base-dark-900 bg-opacity-70 mt-4 custom-scrollbar">
            <RightNav functions={@module.functions} module={@module.name} />
          </div>
        {#else}
          <div />
        {/if}
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    if (assigns[:selected_versions] == socket.assigns[:selected_versions] &&
          Map.get(socket.assigns.library_version || %{}, :id) ==
            Map.get(assigns[:library_version] || %{}, :id)) || !socket.assigns[:loaded_once?] do
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:loaded_once?, false)
       |> load_docs()}
    else
      {:ok,
       socket
       |> assign(assigns)}
    end
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
      case find_module(libraries, selected_versions, mod_name) do
        nil ->
          Logger.warn("No such module found called #{inspect(mod_name)}")
          []

        module ->
          [module]
      end
    end)
  end

  defp find_module(libraries, selected_versions, mod_name) do
    Enum.find_value(libraries, fn library ->
      version = selected_version(library, selected_versions[library.id])

      if version do
        Enum.find(version.modules, &(&1.name == mod_name))
      end
    end)
  end

  defp selected_version(library, selected_version) do
    if selected_version == "latest" do
      latest_version(library)
    else
      Enum.find(library.versions, &(&1.id == selected_version))
    end
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

  def path_to_name(path, name) do
    Enum.map_join(path ++ [name], "-", &DocRoutes.sanitize_name/1)
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

  def show_sidebar(js \\ %JS{}) do
    js
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

  def hide_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#mobile-sidebar-container",
      transition: {
        "transition ease-out duration-75",
        "opacity-100",
        "opacity-0"
      }
    )
  end

  def load_docs(socket) do
    socket = assign_library(socket)

    dsls_query =
      AshHq.Docs.Dsl
      |> Ash.Query.sort(order: :asc)
      |> load_for_search(socket.assigns[:params]["dsl_path"])

    options_query =
      AshHq.Docs.Option
      |> Ash.Query.sort(order: :asc)
      |> load_for_search(socket.assigns[:params]["dsl_path"])

    guides_query =
      AshHq.Docs.Guide
      |> Ash.Query.new()
      |> load_for_search(socket.assigns[:params]["guide"])

    modules_query =
      AshHq.Docs.Module
      |> Ash.Query.sort(order: :asc)
      |> load_for_search(socket.assigns[:params]["module"])

    mix_tasks_query =
      AshHq.Docs.MixTask
      |> Ash.Query.sort(order: :asc)
      |> load_for_search(socket.assigns[:params]["mix_task"])

    extensions_query =
      AshHq.Docs.Extension
      |> Ash.Query.sort(order: :asc)
      |> Ash.Query.load(options: options_query, dsls: dsls_query)
      |> load_for_search(socket.assigns[:params]["extension"])

    new_libraries =
      socket.assigns.libraries
      |> Enum.flat_map(fn library ->
        latest_version = AshHqWeb.Helpers.latest_version(library)

        Enum.filter(library.versions, fn version ->
          (latest_version && version.id == latest_version.id) ||
            version.id == socket.assigns[:selected_versions][library.id] ||
            (socket.assigns[:library_version] &&
               socket.assigns[:library_version].id == version.id) ||
            (socket.assigns.params["version"] &&
               socket.assigns.params["version"] ==
                 version.version)
        end)
      end)
      |> AshHq.Docs.load!(
        [
          extensions: extensions_query,
          guides: guides_query,
          modules: modules_query,
          mix_tasks: mix_tasks_query
        ],
        lazy?: true
      )
      |> Enum.reduce(socket.assigns.libraries, fn library_version, libraries ->
        Enum.map(libraries, fn library ->
          if library.id == library_version.library_id do
            Map.update!(library, :versions, fn versions ->
              Enum.map(versions, fn current_version ->
                if current_version.id == library_version.id do
                  library_version
                else
                  current_version
                end
              end)
            end)
          else
            library
          end
        end)
      end)

    socket
    |> assign(:libraries, new_libraries)
    |> assign_library()
    |> assign_extension()
    |> assign_guide()
    |> assign_module()
    |> assign_mix_task()
    |> assign_dsl()
    |> assign_docs()
  end

  defp load_for_search(query, docs_for) do
    query
    |> Ash.Query.load(AshHq.Docs.Extensions.Search.load_for_search(query.resource))
    |> deselect_doc_attributes()
    |> load_docs_for(docs_for)
  end

  defp load_docs_for(query, nil), do: query
  defp load_docs_for(query, []), do: query

  defp load_docs_for(_query, true) do
    raise "unreachable"
  end

  defp load_docs_for(query, name) when is_list(name) do
    name = Enum.join(name, "/")
    load_docs_for(query, name)
  end

  defp load_docs_for(query, name) do
    query
    |> Ash.Query.load(html_for: %{for: name})
    |> load_additional_docs(name)
  end

  defp load_additional_docs(query, name) do
    query.resource
    |> AshHq.Docs.Extensions.RenderMarkdown.render_attributes()
    |> Enum.reduce(query, fn {source, dest}, query ->
      doc_source = AshHq.Docs.Extensions.Search.doc_attribute(query.resource)

      if doc_source && source == doc_source do
        query
      else
        load = String.to_existing_atom("#{dest}_for")
        Ash.Query.load(query, [{load, %{for: name}}])
      end
    end)
  end

  defp deselect_doc_attributes(query) do
    query.resource
    |> AshHq.Docs.Extensions.RenderMarkdown.render_attributes()
    |> Enum.reduce(query, fn {source, target}, query ->
      Ash.Query.deselect(query, [source, target])
    end)
  end

  defp assign_library(socket) do
    case Enum.find(
           socket.assigns.libraries,
           &(&1.name == socket.assigns.params["library"])
         ) do
      nil ->
        socket
        |> assign(:library, nil)
        |> assign(:library_version, nil)

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
                    &(&1.version == version)
                  )
              end

            if library_version do
              socket =
                assign(
                  socket,
                  library_version: library_version
                )

              if socket.assigns.params["version"] != "latest" &&
                   (!socket.assigns[:library] ||
                      socket.assigns.params["library"] !=
                        socket.assigns.library.name) do
                new_selected_versions =
                  Map.put(socket.assigns.selected_versions, library.id, library_version.id)

                socket
                |> assign(selected_versions: new_selected_versions)
                |> push_event("selected-versions", new_selected_versions)
              else
                socket
              end
            else
              assign(socket, :library_version, nil)
            end
          else
            assign(socket, :library_version, nil)
          end

        assign(socket, :library, library)
    end
  end

  defp assign_extension(socket) do
    if socket.assigns.library_version && socket.assigns[:params]["extension"] do
      extensions = socket.assigns.library_version.extensions

      assign(socket,
        extension:
          Enum.find(extensions, fn extension ->
            extension.sanitized_name == socket.assigns[:params]["extension"]
          end)
      )
    else
      assign(socket, :extension, nil)
    end
  end

  defp assign_guide(socket) do
    guide =
      if socket.assigns[:params]["guide"] && socket.assigns.library_version do
        Enum.find(socket.assigns.library_version.guides, fn guide ->
          guide.route == Enum.join(socket.assigns[:params]["guide"], "/")
        end)
      else
        nil
      end

    assign(socket, :guide, guide)
  end

  defp assign_dsl(socket) do
    case socket.assigns[:params]["dsl_path"] do
      nil ->
        assign(socket, :dsl, nil)

      path ->
        path = Enum.join(path, "/")

        dsl =
          Enum.find(
            socket.assigns.extension.dsls,
            &(&1.sanitized_path == path)
          )

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
          &(&1.sanitized_name == socket.assigns[:params]["module"])
        )

      functions_query =
        AshHq.Docs.Function
        |> Ash.Query.sort(name: :asc, arity: :asc)
        |> load_for_search(socket.assigns[:params]["module"])

      assign(socket,
        module: AshHq.Docs.load!(module, [functions: functions_query], lazy?: true)
      )
    else
      assign(socket, :module, nil)
    end
  end

  defp assign_mix_task(socket) do
    if socket.assigns.library && socket.assigns.library_version &&
         socket.assigns[:params]["mix_task"] do
      mix_task =
        Enum.find(
          socket.assigns.library_version.mix_tasks,
          &(&1.sanitized_name == socket.assigns[:params]["mix_task"])
        )

      assign(socket,
        mix_task: mix_task
      )
    else
      assign(socket, :mix_task, nil)
    end
  end

  defp assign_docs(socket) do
    cond do
      socket.assigns.module ->
        assign(socket,
          docs: socket.assigns.module.html_for,
          doc_path: [socket.assigns.library.name, socket.assigns.module.name],
          options: []
        )

      socket.assigns.mix_task ->
        assign(socket,
          docs: socket.assigns.mix_task.html_for,
          doc_path: [socket.assigns.library.name, socket.assigns.mix_task.name],
          options: []
        )

      socket.assigns.dsl ->
        assign(socket,
          docs: socket.assigns.dsl.html_for,
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
          docs: socket.assigns.extension.html_for,
          doc_path: [socket.assigns.library.name, socket.assigns.extension.name],
          options: []
        )

      socket.assigns.guide ->
        assign(socket,
          docs: socket.assigns.guide.html_for,
          doc_path: [socket.assigns.library.name, socket.assigns.guide.name],
          options: []
        )

      true ->
        assign(socket, docs: "", doc_path: [], dsls: [], options: [])
    end
  end
end
