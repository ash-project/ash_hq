defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc "The left sidebar of the docs pages"
  use Surface.Component

  alias AshHqWeb.DocRoutes
  alias Surface.Components.LivePatch
  alias Phoenix.LiveView.JS

  prop(class, :css_class, default: "")
  prop(libraries, :list, required: true)
  prop(extension, :any, default: nil)
  prop(guide, :any, default: nil)
  prop(library, :any, default: nil)
  prop(library_version, :any, default: nil)
  prop(selected_versions, :map, default: %{})
  prop(id, :string, required: true)
  prop(dsl, :any, required: true)
  prop(module, :any, required: true)
  prop(add_version, :event, required: true)
  prop(remove_version, :event, required: true)
  prop(change_version, :event, required: true)

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <aside
      id={@id}
      class={"grid h-full overflow-y-auto pb-36 w-fit z-40 bg-white dark:bg-base-dark-900", @class}
      aria-label="Sidebar"
    >
      <div class="flex flex-col">
        <div class="text-black dark:text-white font-light w-full px-2 mb-2">
          Including Packages:
        </div>
        <AshHqWeb.Components.VersionPills
          id={"#{@id}-version-pills"}
          libraries={@libraries}
          remove_version={@remove_version}
          change_version={@change_version}
          selected_versions={@selected_versions}
          add_version={@add_version}
        />
      </div>
      <div class="py-3 px-3">
        <ul class="space-y-2">
          <div>
            Guides
          </div>
          {#for {category, guides_by_library} <- guides_by_category_and_library(@libraries, @selected_versions)}
            <div class="text-base-light-500">
              <button phx-click={collapse("#{@id}-#{String.replace(category, " ", "-")}")} class="flex flex-row items-center">
                <div id={"#{@id}-#{String.replace(category, " ", "-")}-chevron-down"}>
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
                </div>
                <div id={"#{@id}-#{String.replace(category, " ", "-")}-chevron-right"} class="-rotate-90" style="display: none;">
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
            {#if !Enum.empty?(get_extensions(@libraries, @selected_versions))}
              <div class="text-base-light-500">
              <button phx-click={collapse("#{@id}-extension")} class="flex flex-row items-center" >
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
                {#for {library, extensions} <- get_extensions(@libraries, @selected_versions)}
                  <li class="ml-3 text-base-light-200 p-1">
                    {library}
                    <ul>
                      {#for extension <- extensions}
                        <li class="ml-1">
                          <LivePatch
                            to={DocRoutes.doc_link(extension, @selected_versions)}
                            class={
                              "flex items-center p-1 text-base font-normal text-base-light-900 rounded-lg dark:text-base-dark-200 hover:bg-base-light-100 dark:hover:bg-base-dark-700"
                            }
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
              {#for {category, modules} <- modules_by_category(@libraries, @selected_versions)}
                <div class="ml-4">
                  <span class="text-sm text-base-light-900 dark:text-base-dark-100">{category}</span>
                </div>
                {#for module <- modules}
                  <li class="ml-4">
                    <LivePatch
                      to={DocRoutes.doc_link(module, @selected_versions)}
                      class={
                        "flex items-center space-x-2 pt-1 text-base font-normal text-base-light-900 rounded-lg dark:text-base-dark-100 hover:bg-base-light-100 dark:hover:bg-base-light-700"
                      }
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
            {#if Enum.any?(dsls, &List.starts_with?(&1.path, dsl.path ++ [dsl.name]))}
              {#if !(@dsl && List.starts_with?(@dsl.path ++ [@dsl.name], path ++ [dsl.name]))}
                <button>
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3" />
                </button>
              {/if}
            {/if}
            <LivePatch
              to={DocRoutes.doc_link(dsl, @selected_versions)}
              class={
                "flex items-center p-1 text-base font-normal rounded-lg hover:text-primary-light-300",
                "text-primary-600 dark:text-primary-dark-400 font-bold": @dsl && @dsl.id == dsl.id
              }
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

  @start_guides ["Tutorials", "Topics", "How To", "Misc"]

  defp guides_by_category_and_library(libraries, selected_versions) do
    libraries =
      Enum.filter(libraries, fn library ->
        selected_versions[library.id] && selected_versions[library.id] != ""
      end)

    library_name_to_order =
      libraries
      |> Enum.sort_by(& &1.order)
      |> Enum.map(& &1.display_name)

    libraries
    |> Enum.flat_map(fn library ->
      library.versions
      |> Enum.find(&Ash.Resource.loaded?(&1, :guides))
      |> case do
        nil ->
          []

        %{guides: guides} ->
          Enum.map(guides, &{&1, library.display_name})
      end
    end)
    |> Enum.group_by(fn {guide, _} ->
      guide.category
    end)
    |> Enum.map(fn {category, guides} ->
      guides_by_library =
        library_name_to_order
        |> Enum.map(fn name ->
          {name,
           Enum.flat_map(guides, fn {guide, guide_lib_name} ->
             if name == guide_lib_name do
               [guide]
             else
               []
             end
           end)}
        end)
        |> Enum.reject(fn {_, guides} ->
          Enum.empty?(guides)
        end)

      {category, guides_by_library}
    end)
    |> partially_alphabetically_sort(@start_guides, [])
  end

  defp get_extensions(libraries, selected_versions) do
    libraries
    |> Enum.filter(fn library ->
      selected_versions[library.id] && selected_versions[library.id] != ""
    end)
    |> Enum.sort_by(& &1.order)
    |> Enum.flat_map(fn library ->
      case Enum.find(library.versions, &Ash.Resource.loaded?(&1, :extensions)) do
        nil ->
          []

        version ->
          case version.extensions do
            [] ->
              []

            extensions ->
              [{library.display_name, extensions}]
          end
      end
    end)
  end

  @last_categories ["Errors"]

  defp modules_by_category(libraries, selected_versions) do
    libraries =
      Enum.filter(libraries, fn library ->
        selected_versions[library.id] && selected_versions[library.id] != ""
      end)

    libraries
    |> Enum.flat_map(fn library ->
      library.versions
      |> Enum.find(&Ash.Resource.loaded?(&1, :modules))
      |> case do
        nil ->
          []

        %{modules: modules} ->
          modules
      end
    end)
    |> Enum.group_by(fn module ->
      module.category
    end)
    |> Enum.sort_by(fn {category, _} -> category end)
    |> Enum.map(fn {category, modules} ->
      {category, Enum.sort_by(modules, & &1.name)}
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
