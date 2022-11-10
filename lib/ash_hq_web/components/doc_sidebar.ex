defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc "The left sidebar of the docs pages"
  use Surface.Component

  alias AshHqWeb.DocRoutes
  alias Surface.Components.LivePatch
  alias Phoenix.LiveView.JS

  import Tails

  prop class, :css_class, default: ""
  prop libraries, :list, required: true
  prop extension, :any, default: nil
  prop guide, :any, default: nil
  prop library, :any, default: nil
  prop library_version, :any, default: nil
  prop selected_versions, :map, default: %{}
  prop id, :string, required: true
  prop dsl, :any, required: true
  prop module, :any, required: true
  prop mix_task, :any, required: true
  prop add_version, :event, required: true
  prop remove_version, :event, required: true
  prop change_version, :event, required: true

  data guides_by_category_and_library, :any
  data extensions, :any
  data modules_by_category, :any
  data mix_tasks_by_category, :any

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    selected_versions =
      if assigns[:library_version] do
        Map.put(
          assigns[:selected_versions] || %{},
          assigns[:library_version].library_id,
          assigns[:library_version].id
        )
      else
        assigns[:selected_versions]
      end

    assigns = assign(assigns, :selected_versions, selected_versions)

    assigns =
      assign(
        assigns,
        guides_by_category_and_library:
          guides_by_category_and_library(
            assigns[:libraries],
            assigns[:library_version],
            assigns[:selected_versions]
          ),
        extensions:
          get_extensions(
            assigns[:libraries],
            assigns[:library_versions],
            assigns[:selected_versions]
          ),
        modules_by_category:
          modules_by_category(
            assigns[:libraries],
            assigns[:library_version],
            assigns[:selected_versions]
          ),
        mix_tasks_by_category:
          mix_tasks_by_category(
            assigns[:libraries],
            assigns[:library_version],
            assigns[:selected_versions]
          )
      )

    ~F"""
    <aside
      id={@id}
      class={"grid h-screen overflow-y-auto pb-36 w-fit z-40 bg-white dark:bg-base-dark-850", @class}
      aria-label="Sidebar"
    >
      <button class="hidden" id={"#{@id}-hide"} phx-click={hide_sidebar()} />
      <div class="flex flex-col">
        <div class="text-black dark:text-white font-light w-full px-2 mb-2">
          Including Packages:
        </div>
        <AshHqWeb.Components.VersionPills
          id={"#{@id}-version-pills"}
          libraries={@libraries}
          remove_version={@remove_version}
          selected_versions={@selected_versions}
        />
      </div>
      <div class="py-3 px-3">
        <ul class="space-y-2">
          <div>
            Guides
          </div>
          {#for {category, guides_by_library} <- @guides_by_category_and_library}
            <div class="text-base-light-500">
              <button
                phx-click={collapse("#{@id}-#{String.replace(category, " ", "-")}")}
                class="flex flex-row items-center"
              >
                <div id={"#{@id}-#{String.replace(category, " ", "-")}-chevron-down"}>
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                </div>
                <div
                  id={"#{@id}-#{String.replace(category, " ", "-")}-chevron-right"}
                  class="-rotate-90"
                  style="display: none;"
                >
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                </div>
                <div>{category}</div>
              </button>
            </div>
            <div id={"#{@id}-#{String.replace(category, " ", "-")}"}>
              {#for {library, guides} <- guides_by_library}
                <li class="ml-3 text-base-light-400 p-1">
                  {library}
                  <ul>
                    {#for guide <- guides}
                      <li class="ml-1">
                        <LivePatch
                          to={DocRoutes.doc_link(guide, @selected_versions)}
                          class={
                            "flex items-center p-1 text-base font-normal text-base-light-900 rounded-lg dark:text-base-dark-200 hover:bg-base-light-100 dark:hover:bg-base-dark-700",
                            "bg-base-light-300 dark:bg-base-dark-600": @guide && @guide.id == guide.id
                          }
                        >
                          <Heroicons.Outline.BookOpenIcon class="h-4 w-4" />
                          <span class="ml-3 mr-2">{guide.name}</span>
                        </LivePatch>
                      </li>
                    {/for}
                  </ul>
                </li>
              {/for}
            </div>
          {/for}
          <div class="mt-4">
            Reference
          </div>
          <div class="ml-2 space-y-2">
            {#if !Enum.empty?(@extensions)}
              <div class="text-base-light-500">
                <button phx-click={collapse("#{@id}-extension")} class="flex flex-row items-center">
                  <div id={"#{@id}-extension-chevron-down"}>
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                  </div>
                  <div id={"#{@id}-extension-chevron-right"} class="-rotate-90" style="display: none;">
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                  </div>
                  Extensions
                </button>
              </div>
            {/if}
            <div id={"#{@id}-extension"}>
              {#for {library, extensions} <- @extensions}
                <li class="ml-3 text-base-light-200 p-1">
                  {library}
                  <ul>
                    {#for extension <- extensions}
                      <li class="ml-1">
                        <LivePatch
                          to={DocRoutes.doc_link(extension, @selected_versions)}
                          class="flex items-center p-1 text-base font-normal text-base-light-900 rounded-lg dark:text-base-dark-200 hover:bg-base-light-100 dark:hover:bg-base-dark-700"
                        >
                          {render_icon(assigns, extension.type)}
                          <span class="ml-3 mr-2">{extension.name}</span>
                        </LivePatch>
                        {#if @extension && @extension.id == extension.id && !Enum.empty?(extension.dsls)}
                          {render_dsls(assigns, extension.dsls, [])}
                        {/if}
                      </li>
                    {/for}
                  </ul>
                </li>
              {/for}
            </div>

            {#if !Enum.empty?(@mix_tasks_by_category)}
              <div class="text-base-light-500">
                <button phx-click={collapse("#{@id}-mix-tasks")} class="flex flex-row items-center">
                  <div id={"#{@id}-mix-tasks-chevron-down"}>
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                  </div>
                  <div id={"#{@id}-mix-tasks-chevron-right"} class="-rotate-90" style="display: none;">
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                  </div>
                  Mix Tasks
                </button>
              </div>
            {/if}
            <div id={"#{@id}-mix-tasks"}>
              {#for {category, mix_tasks} <- @mix_tasks_by_category}
                <div class="ml-4">
                  <span class="text-sm text-base-light-900 dark:text-base-dark-100">{category}</span>
                </div>
                {#for mix_task <- mix_tasks}
                  <li class="ml-4">
                    <LivePatch
                      to={DocRoutes.doc_link(mix_task, @selected_versions)}
                      class="flex items-center space-x-2 pt-1 text-base font-normal text-base-light-900 rounded-lg dark:text-base-dark-100 hover:bg-base-light-100 dark:hover:bg-base-light-700"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        class="w-4 h-4"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M6.75 7.5l3 2.25-3 2.25m4.5 0h3m-9 8.25h13.5A2.25 2.25 0 0021 18V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v12a2.25 2.25 0 002.25 2.25z"
                        />
                      </svg>
                      <span class="">{mix_task.name}</span>
                    </LivePatch>
                  </li>
                {/for}
              {/for}
            </div>

            <div class="text-base-light-500">
              <button phx-click={collapse("#{@id}-modules")} class="flex flex-row items-center">
                <div id={"#{@id}-modules-chevron-down"}>
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                </div>
                <div id={"#{@id}-modules-chevron-right"} class="-rotate-90" style="display: none;">
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                </div>
                Modules
              </button>
            </div>
            <div id={"#{@id}-modules"}>
              {#for {category, modules} <- @modules_by_category}
                <div class="ml-4">
                  <span class="text-sm text-base-light-900 dark:text-base-dark-100">{category}</span>
                </div>
                {#for module <- modules}
                  <li class="ml-4">
                    <LivePatch
                      to={DocRoutes.doc_link(module, @selected_versions)}
                      class="flex items-center space-x-2 pt-1 text-base font-normal text-base-light-900 rounded-lg dark:text-base-dark-100 hover:bg-base-light-100 dark:hover:bg-base-light-700"
                    >
                      <Heroicons.Outline.CodeIcon class="h-4 w-4" />
                      <span class="">{module.name}</span>
                    </LivePatch>
                  </li>
                {/for}
              {/for}
            </div>
          </div>
        </ul>
      </div>
    </aside>
    """
  end

  defp render_dsls(assigns, dsls, path) do
    ~F"""
    <ul class="ml-1 flex flex-col">
      {#for dsl <- Enum.filter(dsls, &(&1.path == path))}
        <li class="border-l pl-1 border-primary-light-600 border-opacity-30">
          <div class="flex flex-row items-center">
            <LivePatch
              to={DocRoutes.doc_link(dsl, @selected_versions)}
              class={classes([
                "flex items-center p-1 font-normal rounded-lg text-black dark:text-white hover:text-primary-light-300",
                "text-primary-light-600 dark:text-primary-dark-400 font-bold":
                  @dsl &&
                    List.starts_with?(@dsl.path ++ [@dsl.name], path ++ [dsl.name])
              ])}
            >
              {dsl.name}
            </LivePatch>
          </div>
          {render_dsls(assigns, dsls, path ++ [dsl.name])}
        </li>
      {/for}
    </ul>
    """
  end

  def render_icon(assigns, "Resource") do
    ~F"""
    <Heroicons.Outline.ServerIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Api") do
    ~F"""
    <Heroicons.Outline.SwitchHorizontalIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "DataLayer") do
    ~F"""
    <Heroicons.Outline.DatabaseIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Flow") do
    ~F"""
    <Heroicons.Outline.MapIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Notifier") do
    ~F"""
    <Heroicons.Outline.MailIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Registry") do
    ~F"""
    <Heroicons.Outline.ViewListIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, _) do
    ~F"""
    <Heroicons.Outline.PuzzleIcon class="h-4 w-4" />
    """
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

  @start_guides ["Tutorials", "Topics", "How To", "Misc"]

  defp guides_by_category_and_library(libraries, library_version, selected_versions) do
    libraries
    |> Enum.map(&{&1, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(fn {_library, version} -> version != nil end)
    |> Enum.sort_by(fn {library, _version} -> library.order end)
    |> Enum.flat_map(fn {library, %{guides: guides}} ->
      guides
      |> Enum.sort_by(& &1.order)
      |> Enum.group_by(& &1.category)
      |> Enum.map(fn {category, guides} -> {category, {library.display_name, guides}} end)
    end)
    |> Enum.group_by(fn {category, _} -> category end, fn {_, lib_guides} -> lib_guides end)
    |> partially_alphabetically_sort(@start_guides, [])
  end

  defp get_extensions(libraries, library_version, selected_versions) do
    libraries
    |> Enum.sort_by(& &1.order)
    |> Enum.map(&{&1.display_name, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(&elem(&1, 1))
    |> Enum.flat_map(fn {name, version} ->
      case version.extensions do
        [] ->
          []

        %Ash.NotLoaded{} ->
          raise "extensions not selected for #{version.version} | #{version.id} of #{name}"

        extensions ->
          [{name, extensions}]
      end
    end)
  end

  @last_categories ["Errors"]

  defp modules_by_category(libraries, library_version, selected_versions) do
    libraries
    |> Enum.map(&selected_version(&1, library_version, selected_versions))
    |> Enum.filter(& &1)
    |> Enum.flat_map(& &1.modules)
    |> Enum.group_by(fn module ->
      module.category
    end)
    |> Enum.sort_by(fn {category, _} -> category end)
    |> Enum.map(fn {category, modules} ->
      {category, Enum.sort_by(modules, & &1.name)}
    end)
    |> partially_alphabetically_sort([], [])
  end

  defp mix_tasks_by_category(libraries, library_version, selected_versions) do
    libraries
    |> Enum.map(&selected_version(&1, library_version, selected_versions))
    |> Enum.filter(& &1)
    |> Enum.flat_map(& &1.mix_tasks)
    |> Enum.group_by(fn mix_task ->
      mix_task.category
    end)
    |> Enum.sort_by(fn {category, _} -> category end)
    |> Enum.map(fn {category, mix_tasks} ->
      {category, Enum.sort_by(mix_tasks, & &1.name)}
    end)
    |> partially_alphabetically_sort([], @last_categories)
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

  defp collapse(id, js \\ %JS{}) do
    js
    |> JS.toggle(to: "##{id}", time: 0)
    |> JS.toggle(to: "##{id}-chevron-down", time: 0)
    |> JS.toggle(to: "##{id}-chevron-right", time: 0)
  end
end
