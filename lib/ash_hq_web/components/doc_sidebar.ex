defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc "The left sidebar of the docs pages"
  use Surface.Component

  alias AshHqWeb.DocRoutes
  alias Surface.Components.Link

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
  prop(sidebar_state, :map, required: true)
  prop(collapse_sidebar, :event, required: true)
  prop(expand_sidebar, :event, required: true)
  prop(add_version, :event, required: true)
  prop(remove_version, :event, required: true)
  prop(change_version, :event, required: true)

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <aside
      id={@id}
      class={"grid h-full overflow-y-auto pb-36 pl-2 w-fit z-40", @class}
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
            <div class="text-gray-500">
              {#if @sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] == "open" ||
                  (@guide && has_selected_guide?(guides_by_library, @guide.id)) ||
                  (@sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] != "closed" &&
                     category == "Tutorials")}
                <button
                  :on-click={@collapse_sidebar}
                  phx-value-id={"guides-#{DocRoutes.sanitize_name(category)}"}
                  class="flex flex-row items-center"
                >
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" /><div>{category}</div>
                </button>
              {#else}
                <button
                  :on-click={@expand_sidebar}
                  phx-value-id={"guides-#{DocRoutes.sanitize_name(category)}"}
                  class="flex flex-row items-center"
                >
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3 mr-1" /><div>{category}</div>
                </button>
              {/if}
            </div>
            {#if @sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] == "open" ||
                (@guide && has_selected_guide?(guides_by_library, @guide.id)) ||
                (@sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] != "closed" &&
                   category == "Tutorials")}
              {#for {library, guides} <- guides_by_library}
                <li class="ml-3 text-gray-400 p-1">
                  {library}
                  <ul>
                    {#for guide <- guides}
                      <li class="ml-1">
                        <Link
                          to={DocRoutes.doc_link(guide, @selected_versions)}
                          class={
                            "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                            "bg-gray-300 dark:bg-gray-600": @guide && @guide.id == guide.id
                          }
                        >
                          <Heroicons.Outline.BookOpenIcon class="h-4 w-4" />
                          <span class="ml-3 mr-2">{guide.name}</span>
                        </Link>
                      </li>
                    {/for}
                  </ul>
                </li>
              {/for}
            {/if}
          {/for}
          <div class="mt-4">
            Reference
          </div>
          <div class="ml-2 space-y-2">
            {#if !Enum.empty?(get_extensions(@libraries, @selected_versions))}
              <div class="text-gray-500">
                {#if @sidebar_state["extensions"] == "open" || @extension}
                  <button
                    :on-click={@collapse_sidebar}
                    phx-value-id="extensions"
                    class="flex flex-row items-center"
                  >
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />Extensions
                  </button>
                {#else}
                  <button :on-click={@expand_sidebar} phx-value-id="extensions" class="flex flex-row items-center">
                    <Heroicons.Outline.ChevronRightIcon class="w-3 h-3 mr-1" />Extensions
                  </button>
                {/if}
              </div>
            {/if}
            {#if @sidebar_state["extensions"] == "open" || @extension}
              {#for {library, extensions} <- get_extensions(@libraries, @selected_versions)}
                <li class="ml-3 text-gray-400 p-1">
                  {library}
                  <ul>
                    {#for extension <- extensions}
                      <li class="ml-1">
                        <Link
                          to={DocRoutes.doc_link(extension, @selected_versions)}
                          class={
                            "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                            "dark:bg-gray-600": @extension && @extension.id == extension.id
                          }
                        >
                          {render_icon(assigns, extension.type)}
                          <span class="ml-3 mr-2">{extension.name}</span>
                        </Link>
                        {#if @extension && @extension.id == extension.id && !Enum.empty?(extension.dsls)}
                          {render_dsls(assigns, extension.dsls, [])}
                        {/if}
                      </li>
                    {/for}
                  </ul>
                </li>
              {/for}
            {/if}

            <div class="text-gray-500">
              {#if @sidebar_state["modules"] == "open" || @module}
                <button :on-click={@collapse_sidebar} phx-value-id="modules" class="flex flex-row items-center">
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />Modules
                </button>
              {#else}
                <button :on-click={@expand_sidebar} phx-value-id="modules" class="flex flex-row items-center">
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3 mr-1" />Modules
                </button>
              {/if}
            </div>
            {#if @sidebar_state["modules"] == "open" || @module}
              {#for {category, modules} <- modules_by_category(@libraries, @selected_versions)}
                <div class="ml-4">
                  <span class="text-sm text-gray-900 dark:text-gray-500">{category}</span>
                </div>
                {#for module <- modules}
                  <li class="ml-4">
                    <Link
                      to={DocRoutes.doc_link(module, @selected_versions)}
                      class={
                        "flex items-center space-x-2 pt-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                        "dark:bg-gray-600": @module && @module.id == module.id
                      }
                    >
                      <Heroicons.Outline.CodeIcon class="h-4 w-4" />
                      <span class="">{module.name}</span>
                    </Link>
                  </li>
                {/for}
              {/for}
            {/if}
          </div>
        </ul>
      </div>
    </aside>
    """
  end

  defp has_selected_guide?(guides_by_library, guide_id) do
    Enum.any?(guides_by_library, fn {_, guides} ->
      Enum.any?(guides, &(&1.id == guide_id))
    end)
  end

  defp render_dsls(assigns, dsls, path) do
    ~F"""
    <ul class="ml-1 flex flex-col">
      {#for dsl <- Enum.filter(dsls, &(&1.path == path))}
        <li class="border-l pl-1 border-orange-600 border-opacity-30">
          <div class="flex flex-row items-center">
            {#if Enum.any?(dsls, &List.starts_with?(&1.path, dsl.path ++ [dsl.name]))}
              {#if !(@dsl && List.starts_with?(@dsl.path ++ [@dsl.name], path ++ [dsl.name]))}
                {#if @sidebar_state[dsl.id] == "open"}
                  <button :on-click={@collapse_sidebar} phx-value-id={dsl.id}>
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3" />
                  </button>
                {#else}
                  <button :on-click={@expand_sidebar} phx-value-id={dsl.id}>
                    <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
                  </button>
                {/if}
              {/if}
            {/if}
            <Link
              to={DocRoutes.doc_link(dsl, @selected_versions)}
              class={
                "flex items-center p-1 text-base font-normal rounded-lg hover:text-orange-300",
                "text-orange-600 dark:text-orange-400 font-bold": @dsl && @dsl.id == dsl.id
              }
            >
              {dsl.name}
            </Link>
          </div>
          {#if @sidebar_state[dsl.id] == "open" ||
              (@dsl && List.starts_with?(@dsl.path ++ [@dsl.name], path ++ [dsl.name]))}
            {render_dsls(assigns, dsls, path ++ [dsl.name])}
          {/if}
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
end
