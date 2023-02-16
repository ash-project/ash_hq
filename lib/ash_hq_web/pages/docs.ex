defmodule AshHqWeb.Pages.Docs do
  @moduledoc "The page for showing documentation"
  use Surface.LiveComponent

  import AshHqWeb.Helpers

  alias AshHqWeb.Components.{CalloutText, DocSidebar, RightNav, Tag}
  alias AshHqWeb.Components.Docs.{DocPath, Functions, SourceLink}
  alias AshHqWeb.DocRoutes
  alias Phoenix.LiveView.JS
  alias Surface.Components.LivePatch
  require Logger
  require Ash.Query

  prop(change_versions, :event, required: true)
  prop(selected_versions, :map, required: true)
  prop(libraries, :list, default: [])
  prop(uri, :string)
  prop(remove_version, :event)
  prop(add_version, :event)
  prop(change_version, :event)
  prop(params, :map, required: true)
  prop(show_catalogue_call_to_action, :boolean)

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
  data(mix_task, :any)
  data(positional_options, :list)
  data(description, :string)
  data(title, :string)
  data(sidebar_data, :any)
  data(not_found, :boolean, default: false)

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="flex flex-col xl:flex-row justify-center">
      <head>
        <meta property="og:title" content={@title}>
        <meta property="og:description" content={@description}>
      </head>
      <div class="xl:hidden sticky top-20 z-40 h-14 bg-white dark:bg-base-dark-850 flex flex-row justify-start w-full space-x-6 items-center border-b border-base-light-300 dark:border-base-dark-700 py-3">
        <button phx-click={show_sidebar()}>
          <Heroicons.Outline.MenuIcon class="w-8 h-8 ml-4" />
        </button>
        <button id={"#{@id}-hide"} class="hidden" phx-click={hide_sidebar()} />
        {#if @doc_path && @doc_path != []}
          <DocPath doc_path={@doc_path} />
        {/if}
      </div>
      <span class="grid xl:hidden z-40">
        <div
          id="mobile-sidebar-container"
          class="hidden fixed transition sidebar-container overflow-y-auto z-40 border-r border-b border-base-light-300 dark:border-base-dark-700"
          :on-click-away={hide_sidebar()}
        >
          <DocSidebar
            id="mobile-sidebar"
            class="max-w-sm p-2 pr-4"
            libraries={@libraries}
            remove_version={@remove_version}
            selected_versions={@selected_versions}
            sidebar_data={@sidebar_data}
          />
        </div>
      </span>
      <div class="grow w-full flex flex-row max-w-[1800px] justify-between md:space-x-12">
        <div class="sidebar-container sticky overflow-y-auto overflow-x-hidden shrink-0 top-20 xl:border-r xl:border-b xl:border-base-light-300 xl:dark:border-base-dark-700 lg:pr-2 lg:pt-4">
          <DocSidebar
            id="sidebar"
            class="hidden xl:block w-80"
            libraries={@libraries}
            remove_version={@remove_version}
            selected_versions={@selected_versions}
            sidebar_data={@sidebar_data}
          />
        </div>
        <div
          id="docs-window"
          :if={@not_found}
          class="w-full shrink prose prose-td:pl-0 max-w-6xl bg-white dark:bg-base-dark-850 dark:prose-invert md:pr-8 md:mt-4 px-4 md:px-auto mx-auto overflow-x-auto overflow-y-hidden"
        >
          <div class="w-full nav-anchor text-black dark:text-white relative py-4 md:py-auto">
            We couldn't find that page.
          </div>
        </div>
        <div
          id="docs-window"
          :if={!@not_found}
          class="w-full shrink prose prose-td:pl-0 max-w-6xl bg-white dark:bg-base-dark-850 dark:prose-invert md:pr-8 md:mt-4 px-4 md:px-auto mx-auto overflow-x-auto overflow-y-hidden"
        >
          <div
            id="module-docs"
            class="w-full nav-anchor text-black dark:text-white relative py-4 md:py-auto"
          >
            <.catalogue_call_to_action :if={@show_catalogue_call_to_action} />
            {#if @extension && !@dsl}
              <h1>{@extension.name}</h1>
            {/if}
            {#if @module}
              <h1>{@module.name} <SourceLink module_or_function={@module} library={@library} library_version={@library_version} /></h1>
            {/if}
            {#if @mix_task}
              <h1>{@mix_task.name} <SourceLink
                  module_or_function={@mix_task}
                  library={@library}
                  library_version={@library_version}
                /></h1>
            {/if}
            <.github_guide_link
              :if={@guide}
              guide={@guide}
              library={@library}
              library_version={@library_version}
            />
            <.docs doc_path={@doc_path} docs={@docs} />
            {#if @extension && !@dsl && !@guide}
              {#case Enum.count_until(Stream.filter(@extension.dsls, &(&1.type == :section)), 2)}
                {#match 0}
                  <div />
                {#match 1}
                  <h2>
                    DSL
                  </h2>
                {#match 2}
                  <h2>
                    DSL Sections
                  </h2>
              {/case}
              <ul>
                {#for section <- Enum.filter(@extension.dsls, &(&1.type == :section))}
                  <li>
                    <LivePatch to={DocRoutes.doc_link(section, @selected_versions)}>{section.name}</LivePatch>
                  </li>
                {/for}
              </ul>
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
                    <LivePatch to={DocRoutes.doc_link(mod, @selected_versions)}>{mod.name}</LivePatch>
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
                    <LivePatch to={DocRoutes.doc_link(child, @selected_versions)}>{child.name}</LivePatch>
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
                    {#if @dsl.arg_defaults not in [%{}, nil]}
                      <th>Default</th>
                    {/if}
                    <th>Doc</th>
                  </tr>
                  {#for option <- positional_options(@options)}
                    <tr id={"#{option.sanitized_path}/#{option.name}"}>
                      <td>
                        <div class="flex flex-row items-baseline">
                          <LivePatch to={"##{DocRoutes.sanitize_name(option.name)}"}>
                            <Heroicons.Outline.LinkIcon class="h-3 w-3 mr-2" />
                          </LivePatch>
                          <div class="flex flex-row space-x-2">
                            <CalloutText text={option.name} />
                            {render_tags(assigns, %{
                              option
                              | required: option.required && !Map.has_key?(@dsl.arg_defaults || %{}, option.name)
                            })}
                          </div>
                        </div>
                      </td>
                      <td>
                        {option.type}
                      </td>
                      {#if @dsl.arg_defaults not in [%{}, nil]}
                        <th>{Map.get(@dsl.arg_defaults || %{}, option.name)}</th>
                      {/if}
                      <td>
                        {raw(option.doc_html)}
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
                  <th>Default</th>
                  <th>Doc</th>
                </tr>
                {#for %{argument_index: nil} = option <- @options}
                  <tr id={"#{option.sanitized_path}/#{option.name}"}>
                    <td id={DocRoutes.sanitize_name(option.name)}>
                      <div class="flex flex-row items-baseline">
                        <LivePatch to={"##{DocRoutes.sanitize_name(option.name)}"}>
                          <Heroicons.Outline.LinkIcon class="h-3 w-3 mr-2" />
                        </LivePatch>
                        <CalloutText text={option.name} />
                        {render_tags(assigns, option)}
                      </div>
                    </td>
                    <td>
                      {option.type}
                    </td>
                    <td>
                      {if option.default == "nil", do: nil, else: option.default}
                    </td>
                    <td>
                      {raw(option.doc_html)}
                    </td>
                  </tr>
                {/for}
              {/if}
            </table>
          </div>

          <footer class="p-2 sm:justify-center">
            <div class="md:flex md:justify-around items-center">
              <LivePatch to="/">
                <img class="h-6 md:h-10 hidden dark:block" src="/images/ash-framework-dark.png">
                <img class="h-6 md:h-10 dark:hidden" src="/images/ash-framework-light.png">
              </LivePatch>
              <a href="https://github.com/ash-project" class="hover:underline">Source</a>
              <a href="https://github.com/ash-project/ash_hq/issues/new/choose" class="hover:underline">Report an issue</a>
            </div>
          </footer>
        </div>
        {#if @module}
          <div class="sidebar-container hidden lg:block lg:w-80 sticky top-36 xl:top-20 shrink-0 overflow-y-auto overflow-x-hidden dark:bg-base-dark-850 bg-opacity-70 mt-4">
            <RightNav functions={@module.functions} module={@module.name} />
          </div>
        {#else}
          <!-- empty div to preserve flex row spacing -->
          <div />
        {/if}
      </div>
    </div>
    """
  end

  def github_guide_link(assigns) do
    ~F"""
    <a
      href={source_link(@guide, @library, @library_version)}
      target="_blank"
      class="float-right no-underline mt-1 ml-2 hidden lg:block"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="w-6 h-6 inline-block mr-1 -mt-1 dark:fill-white fill-base-light-600"
        viewBox="0 0 24 24"
      >
        <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
      </svg>
      <span class="underline">View this guide on GitHub</span>
      <Heroicons.Outline.ExternalLinkIcon class="w-6 h-6 inline-block -mt-1" />
    </a>
    """
  end

  def docs(assigns) do
    ~F"""
    <div id={docs_container_id(@doc_path)}>
      {raw(@docs)}
    </div>
    """
  end

  def catalogue_call_to_action(assigns) do
    ~F"""
    <div
      class="bg-blue-500 text-white px-4 py-2 mb-8 cursor-pointer flex justify-between items-center"
      id="catalogue-call-to-action"
      :on-click={AshHqWeb.AppViewLive.toggle_catalogue()}
    >
      <span>View the full range of Ash libraries for authentication, soft deletion, GraphQL and more</span>
      <button
        id="close-search"
        class="h-6 w-6 cursor-pointer"
        :on-click="dismiss_catalogue_call_to_action"
      >
        <Heroicons.Outline.XIcon class="h-6 w-6" />
      </button>
    </div>
    """
  end

  def update(assigns, socket) do
    if socket.assigns[:loaded_once?] &&
         assigns[:selected_versions] == socket.assigns[:selected_versions] do
      {:ok, socket |> assign(Map.delete(assigns, :libraries)) |> load_docs()}
    else
      {:ok,
       socket
       |> assign(assigns)
       |> assign_libraries()
       |> load_docs()
       |> assign_sidebar_content()
       |> assign(:loaded_once?, true)}
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

  def assign_libraries(socket) do
    socket = assign_library(socket)

    guides_query =
      AshHq.Docs.Guide
      |> Ash.Query.new()
      |> load_for_search()

    modules_query =
      AshHq.Docs.Module
      |> Ash.Query.sort(order: :asc)
      |> load_for_search()

    mix_tasks_query =
      AshHq.Docs.MixTask
      |> Ash.Query.sort(order: :asc)
      |> load_for_search()

    extensions_query =
      AshHq.Docs.Extension
      |> Ash.Query.sort(order: :asc)
      |> load_for_search()

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

    assign(socket, :libraries, new_libraries)
  end

  def load_docs(socket) do
    socket
    |> assign_library()
    |> assign_extension()
    |> assign_guide()
    |> assign_module()
    |> assign_mix_task()
    |> assign_dsl()
    |> assign_fallback_guide()
    |> assign_docs()
  end

  defp assign_sidebar_content(socket) do
    sidebar_data = [
      %{
        name: "Guides",
        id: "guides",
        categories:
          guides_by_category_and_library(
            socket.assigns[:libraries],
            socket.assigns[:library_version],
            socket.assigns[:selected_versions],
            socket.assigns[:guide]
          )
      },
      %{
        name: "DSLs & Extensions",
        id: "dsls",
        categories:
          get_extensions(
            socket.assigns[:libraries],
            socket.assigns[:library_version],
            socket.assigns[:selected_versions],
            socket.assigns[:extension]
          )
      },
      %{
        name: "Code",
        id: "code",
        categories:
          modules_by_category_and_library(
            socket.assigns[:libraries],
            socket.assigns[:library_version],
            socket.assigns[:selected_versions],
            socket.assigns[:module]
          )
      },
      %{
        name: "Mix Tasks",
        id: "mix-tasks",
        categories:
          mix_tasks_by_category_and_library(
            socket.assigns[:libraries],
            socket.assigns[:library_version],
            socket.assigns[:selected_versions],
            socket.assigns[:mix_task]
          )
      }
    ]

    assign(socket, sidebar_libraries: socket.assigns.libraries, sidebar_data: sidebar_data)
  end

  @start_guides ["Tutorials", "Topics", "How To", "Misc"]

  defp guides_by_category_and_library(libraries, library_version, selected_versions, active_guide) do
    libraries
    |> Enum.map(&{&1, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(fn {_library, version} -> version != nil end)
    |> Enum.sort_by(fn {library, _version} -> library.order end)
    |> Enum.flat_map(fn {library, %{guides: guides}} ->
      guides
      |> Enum.sort_by(& &1.order)
      |> Enum.group_by(& &1.category, fn guide ->
        %{
          id: guide.id,
          name: guide.name,
          to: DocRoutes.doc_link(guide, selected_versions),
          active?: active_guide && active_guide.id == guide.id
        }
      end)
      |> Enum.map(fn {category, guides} -> {category, {library.display_name, guides}} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> partially_alphabetically_sort(@start_guides, [])
  end

  @last_categories ["Errors"]

  defp modules_by_category_and_library(
         libraries,
         library_version,
         selected_versions,
         active_module
       ) do
    libraries
    |> Enum.map(&{&1, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(fn {_library, version} -> version != nil end)
    |> Enum.sort_by(fn {library, _version} -> library.order end)
    |> Enum.flat_map(fn {library, %{modules: modules}} ->
      modules
      |> Enum.sort_by(& &1.order)
      |> Enum.group_by(& &1.category, fn module ->
        %{
          id: module.id,
          name: module.name,
          to: DocRoutes.doc_link(module, selected_versions),
          active?: active_module && active_module.id == module.id
        }
      end)
      |> Enum.map(fn {category, modules} -> {category, {library.display_name, modules}} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> partially_alphabetically_sort([], @last_categories)
  end

  defp mix_tasks_by_category_and_library(
         libraries,
         library_version,
         selected_versions,
         active_mix_task
       ) do
    libraries
    |> Enum.map(&{&1, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(fn {_library, version} -> version != nil end)
    |> Enum.sort_by(fn {library, _version} -> library.order end)
    |> Enum.flat_map(fn {library, %{mix_tasks: mix_tasks}} ->
      mix_tasks
      |> Enum.sort_by(& &1.order)
      |> Enum.group_by(& &1.category, fn mix_task ->
        %{
          id: mix_task.id,
          name: mix_task.name,
          to: DocRoutes.doc_link(mix_task, selected_versions),
          active?: active_mix_task && active_mix_task.id == mix_task.id
        }
      end)
      |> Enum.map(fn {category, mix_tasks} -> {category, {library.display_name, mix_tasks}} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> partially_alphabetically_sort([], @last_categories)
  end

  defp selected_version(library, library_version, selected_versions) do
    selected_version = selected_versions[library.id]

    if library_version && library_version.library_id == library.id do
      library_version
    else
      if selected_version == "latest" do
        AshHqWeb.Helpers.latest_version(library)
      else
        if selected_version not in [nil, ""] do
          Enum.find(library.versions, &(&1.id == selected_version))
        end
      end
    end
  end

  defp partially_alphabetically_sort(keyed_list, first, last) do
    {first_items, rest} =
      Enum.split_with(keyed_list, fn {key, _} ->
        key in first
      end)

    {last_items, rest} =
      Enum.split_with(rest, fn {key, _} ->
        key in last
      end)

    first_items
    |> Enum.sort_by(fn {key, _} ->
      Enum.find_index(first, &(&1 == key))
    end)
    |> Enum.concat(Enum.sort_by(rest, &elem(&1, 0)))
    |> Enum.concat(
      Enum.sort_by(last_items, fn {key, _} ->
        Enum.find_index(last, &(&1 == key))
      end)
    )
  end

  def slug(string) do
    string
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.replace(~r/[^a-z0-9-_]/, "-")
  end

  @target_order ["Ash.Resource", "Ash.Api", "Ash.Flow", "Ash.Registry"]

  defp get_extensions(libraries, library_version, selected_versions, active_extension) do
    libraries
    |> Enum.map(&{&1, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(fn {_library, version} -> version != nil end)
    |> Enum.sort_by(fn {library, _version} -> library.order end)
    |> Enum.flat_map(fn {library, %{extensions: extensions}} ->
      extensions
      |> Enum.sort_by(& &1.order)
      |> Enum.group_by(& &1.target, fn extension ->
        %{
          id: extension.id,
          name: extension.module || extension.name,
          to: DocRoutes.doc_link(extension, selected_versions),
          active?: active_extension && active_extension.id == extension.id
        }
      end)
      |> Enum.map(fn {target, extensions} -> {target, {library.display_name, extensions}} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> partially_alphabetically_sort(@target_order, [])
  end

  defp assign_fallback_guide(socket) do
    if socket.assigns[:library_version] &&
         !(socket.assigns[:dsl] || socket.assigns[:mix_task] || socket.assigns[:guide] ||
             socket.assigns[:extension] || socket.assigns[:module]) do
      guide =
        Enum.find(socket.assigns.library_version.guides, fn guide ->
          guide.default
        end) ||
          Enum.find(socket.assigns.library_version.guides, fn guide ->
            String.contains?(guide.sanitized_name, "started")
          end) || Enum.at(socket.assigns.library_version.guides, 0)

      guide = guide |> reselect!(:text_html)

      assign(socket, guide: guide)
    else
      socket
    end
  end

  defp reselect!(%resource{} = record, field) do
    if Ash.Resource.selected?(record, field) do
      record
    else
      # will blow up if pkey is not an id or if its not a docs resource
      # but w/e
      value =
        resource
        |> Ash.Query.select(field)
        |> Ash.Query.filter(id == ^record.id)
        |> AshHq.Docs.read_one!()
        |> Map.get(field)

      Map.put(record, field, value)
    end
  end

  defp reselect_and_get!(record, field) do
    record
    |> reselect!(field)
    |> Map.get(field)
  end

  defp load_for_search(query) do
    query
    |> Ash.Query.load(AshHq.Docs.Extensions.Search.load_for_search(query.resource))
    |> deselect_doc_attributes()
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
        assign(socket,
          not_found: true,
          library: Enum.find(socket.assigns.libraries, &(&1.name == "ash"))
        )

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

            if is_nil(library_version) do
              assign(socket,
                not_found: true,
                library_version: AshHqWeb.Helpers.latest_version(library)
              )
            else
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
            end
          else
            assign(socket, :library_version, nil)
          end

        assign(socket, :library, library)
    end
  end

  defp assign_extension(socket) do
    if socket.assigns.library_version && socket.assigns[:params]["extension"] do
      extension =
        Enum.find(socket.assigns.library_version.extensions, fn extension ->
          extension.sanitized_name == socket.assigns[:params]["extension"] ||
            AshHqWeb.DocRoutes.sanitize_name(extension.module) ==
              socket.assigns[:params]["extension"]
        end)

      if is_nil(extension) do
        assign(socket, extension: nil, not_found: true)
      else
        dsls_query =
          AshHq.Docs.Dsl
          |> Ash.Query.sort(order: :asc)
          |> load_for_search()

        options_query =
          AshHq.Docs.Option
          |> Ash.Query.sort(order: :asc)
          |> load_for_search()

        extension = AshHq.Docs.load!(extension, dsls: dsls_query, options: options_query)

        assign(socket,
          extension: extension
        )
      end
    else
      assign(socket, :extension, nil)
    end
  end

  defp assign_guide(socket) do
    guide_route = socket.assigns[:params]["guide"]

    guide =
      if guide_route && socket.assigns.library_version do
        guide_route = Enum.map(List.wrap(guide_route), &String.trim_trailing(&1, ".md"))

        Enum.find(socket.assigns.library_version.guides, fn guide ->
          matches_path?(guide, guide_route) || matches_name?(guide, guide_route)
        end)
      end

    assign(socket, :guide, guide)
  end

  defp matches_path?(guide, guide_route) do
    guide.sanitized_route == DocRoutes.sanitize_name(Enum.join(guide_route, "/"), true)
  end

  defp matches_name?(guide, list) do
    guide_name = List.last(list)
    DocRoutes.sanitize_name(guide.name) == DocRoutes.sanitize_name(guide_name)
  end

  defp assign_dsl(socket) do
    case socket.assigns[:params]["dsl_path"] do
      nil ->
        assign(socket, :dsl, nil)

      path ->
        if socket.assigns.extension do
          path = Enum.join(path, "/")

          dsl =
            Enum.find(
              socket.assigns.extension.dsls,
              &(&1.sanitized_path == path)
            )

          if is_nil(dsl) do
            assign(socket, dsl: nil, not_found: true)
          else
            socket
            |> assign(
              :dsl,
              dsl
            )
          end
        else
          assign(socket, dsl: nil, not_found: true)
        end
    end
  end

  defp assign_module(socket) do
    if !socket.assigns.extension && socket.assigns.library && socket.assigns.library_version &&
         socket.assigns[:params]["module"] do
      module =
        Enum.find(
          socket.assigns.library_version.modules,
          &(&1.sanitized_name == socket.assigns[:params]["module"])
        )

      if is_nil(module) do
        assign(socket, module: nil, not_found: true)
      else
        functions_query =
          AshHq.Docs.Function
          |> Ash.Query.sort(name: :asc, arity: :asc)
          |> load_for_search()
          |> Ash.Query.load(:doc_html)

        assign(socket,
          module: AshHq.Docs.load!(module, [functions: functions_query], lazy?: true)
        )
      end
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

      if mix_task do
        assign(socket,
          mix_task: mix_task
        )
      else
        assign(socket, mix_task: nil, not_found: true)
      end
    else
      assign(socket, :mix_task, nil)
    end
  end

  defp assign_docs(socket) do
    cond do
      socket.assigns.module ->
        send(self(), {:page_title, socket.assigns.module.name})

        assign(socket,
          docs: socket.assigns.module |> reselect_and_get!(:doc_html),
          title: "Module: #{socket.assigns.module.name}",
          description: "View the documentation for #{socket.assigns.module.name} on Ash HQ.",
          doc_path: [socket.assigns.library.name, socket.assigns.module.name],
          options: []
        )

      socket.assigns.mix_task ->
        send(self(), {:page_title, socket.assigns.mix_task.name})

        assign(socket,
          docs: socket.assigns.mix_task |> reselect_and_get!(:doc_html),
          title: "Mix Task: #{socket.assigns.mix_task.name}",
          description: "View the documentation for #{socket.assigns.mix_task.name} on Ash HQ.",
          doc_path: [socket.assigns.library.name, socket.assigns.mix_task.name],
          options: []
        )

      socket.assigns.dsl ->
        send(self(), {:page_title, socket.assigns.dsl.name})

        meta_name =
          Enum.join(
            [
              socket.assigns.library.name,
              socket.assigns.extension.name
            ] ++ socket.assigns.dsl.path ++ [socket.assigns.dsl.name],
            " > "
          )

        meta_type = String.capitalize(to_string(socket.assigns.dsl.type))

        dsl = AshHq.Docs.load!(socket.assigns.dsl, [:doc_html], lazy?: true)

        options =
          Enum.filter(
            socket.assigns.extension.options,
            &(&1.path == socket.assigns.dsl.path ++ [socket.assigns.dsl.name])
          )
          |> AshHq.Docs.load!(:doc_html, lazy?: true)

        assign(socket,
          docs: dsl.doc_html,
          title: "DSL #{meta_type}: #{meta_name}",
          description: "View the documentation for DSL #{meta_type}: #{meta_name} on Ash HQ.",
          doc_path:
            [
              socket.assigns.library.name,
              socket.assigns.extension.name
            ] ++ socket.assigns.dsl.path ++ [socket.assigns.dsl.name],
          options: options
        )

      socket.assigns.extension ->
        send(self(), {:page_title, socket.assigns.extension.name})

        assign(socket,
          docs: socket.assigns.extension |> reselect_and_get!(:doc_html),
          title: "Extension: #{socket.assigns.extension.name}",
          description: "View the documentation for #{socket.assigns.extension.name} on Ash HQ.",
          doc_path: [socket.assigns.library.name, socket.assigns.extension.name],
          options: []
        )

      socket.assigns.guide ->
        send(self(), {:page_title, socket.assigns.guide.name})

        assign(socket,
          title: "Guide: #{socket.assigns.guide.name}",
          docs: socket.assigns.guide |> reselect_and_get!(:text_html),
          description: "Read the \"#{socket.assigns.guide.name}\" guide on Ash HQ",
          doc_path: [socket.assigns.library.name, socket.assigns.guide.name],
          options: []
        )

      true ->
        assign(socket,
          docs: "",
          title: "Ash Framework",
          description: default_description(),
          doc_path: [],
          dsls: [],
          options: []
        )
    end
  end

  defp default_description do
    "A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
  end

  # workaround for https://github.com/patrick-steele-idem/morphdom/pull/231
  # Adding a unique ID on the container for the rendered docs prevents morphdom
  # merging them incorrectly.
  defp docs_container_id(doc_path) do
    ["docs-container" | doc_path]
    |> Enum.join("-")
    |> String.replace(~r/[^A-Za-z0-9_]/, "-")
    |> String.downcase()
  end
end
