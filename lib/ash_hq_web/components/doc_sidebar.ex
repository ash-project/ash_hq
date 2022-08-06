defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc "The left sidebar of the docs pages"
  use Surface.Component

  alias AshHqWeb.DocRoutes
  alias Surface.Components.LiveRedirect

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
  prop sidebar_state, :map, required: true
  prop collapse_sidebar, :event, required: true
  prop expand_sidebar, :event, required: true

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <aside id={@id} class={"grid h-full overflow-y-auto pb-36 w-2/12", @class} aria-label="Sidebar">
      <div class="py-3 px-3">
        <ul class="space-y-2">
          <div>
            Guides
          </div>
          {#for {category, guides} <- guides_by_category(@libraries)}
            <div class="text-gray-500">
              {#if @sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] == "open" || (@guide && Enum.any?(guides, &(&1.id == @guide.id))) || (@sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] != "closed" && category == "Tutorials")}
                <button :on-click={@collapse_sidebar} phx-value-id={"guides-#{DocRoutes.sanitize_name(category)}"} class="flex flex-row items-center">
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" /><div>{category}</div>
                </button>
              {#else}
                <button :on-click={@expand_sidebar} phx-value-id={"guides-#{DocRoutes.sanitize_name(category)}"} class="flex flex-row items-center">
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3 mr-1" /><div>{category}</div>
                </button>
              {/if}
            </div>
            {#if @sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] == "open" || (@guide && Enum.any?(guides, &(&1.id == @guide.id))) || (@sidebar_state["guides-#{DocRoutes.sanitize_name(category)}"] != "closed" && category == "Tutorials")}
              {#for guide <- guides}
                <li class="ml-3">
                  <LiveRedirect
                    to={DocRoutes.doc_link(guide, @selected_versions)}
                    class={
                      "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                      "bg-gray-300 dark:bg-gray-600": @guide && @guide.id == guide.id
                    }
                  >
                    <Heroicons.Outline.BookOpenIcon class="h-4 w-4" />
                    <span class="ml-3 mr-2">{guide.name}</span>
                  </LiveRedirect>
                </li>
              {/for}
            {/if}
          {/for}
          <div class="mt-4">
            Reference
          </div>
          <div class="ml-2 space-y-2">
            <div class="text-gray-500">
              {#if @sidebar_state["extensions"] == "open" || @extension}
                <button :on-click={@collapse_sidebar} phx-value-id="extensions" class="flex flex-row items-center">
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1"/>Extensions
                </button>
              {#else}
                <button :on-click={@expand_sidebar} phx-value-id="extensions" class="flex flex-row items-center">
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3 mr-1"/>Extensions
                </button>
              {/if}
            </div>
            {#if @sidebar_state["extensions"] == "open" || @extension}
              {#for extension <- get_extensions(@libraries)}
                <li class="ml-3">
                  <LiveRedirect
                    to={DocRoutes.doc_link(extension, @selected_versions)}
                    class={
                      "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                      "dark:bg-gray-600": @extension && @extension.id == extension.id
                    }
                  >
                    <span class="ml-3 mr-2">{extension.name}</span>
                    {render_icon(assigns, extension.type)}
                  </LiveRedirect>
                  {#if @extension && @extension.id == extension.id && !Enum.empty?(extension.dsls)}
                    {render_dsls(assigns, extension.dsls, [])}
                  {/if}
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
              {#for {category, modules} <- modules_and_categories(@libraries)}
                <div class="ml-4">
                  <span class="text-sm text-gray-900 dark:text-gray-500">{category}</span>
                </div>
                {#for module <- modules}
                  <li class="ml-4">
                    <LiveRedirect
                      to={DocRoutes.doc_link(module, @selected_versions)}
                      class={
                        "flex items-center pt-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                        "dark:bg-gray-600": @module && @module.id == module.id
                      }
                    >
                      <span class="ml-3 mr-2">{module.name}</span>
                      <Heroicons.Outline.CodeIcon class="h-4 w-4" />
                    </LiveRedirect>
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

  defp modules_and_categories(libraries) do
    libraries
    |> Enum.flat_map(fn library ->
      library.versions
      |> Enum.find(&Ash.Resource.Info.loaded?(&1, :modules))
      |> case do
        nil ->
          []

        %{modules: modules} ->
          modules
      end
    end)
    |> Enum.group_by(&{&1.category_index, &1.category})
    |> Enum.sort_by(fn {{index, _}, _} ->
      index
    end)
    |> Enum.map(fn {{_, category}, list} ->
      {category, list}
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
            <LiveRedirect
              to={DocRoutes.doc_link(dsl, @selected_versions)}
              class={
                "flex items-center p-1 text-base font-normal rounded-lg hover:text-orange-300",
                "text-orange-600 dark:text-orange-400 font-bold": @dsl && @dsl.id == dsl.id
              }
            >
              {dsl.name}
            </LiveRedirect>
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

  defp guides_by_category(libraries) do
    libraries
    |> Enum.flat_map(fn library ->
      library.versions
      |> Enum.find(&Ash.Resource.Info.loaded?(&1, :guides))
      |> case do
        nil ->
          []

        %{guides: guides} ->
          guides
      end
    end)
    |> Enum.group_by(& &1.category)
    |> Enum.sort_by(fn {category, _guides} ->
      Enum.find_index(["Tutorials", "Topics", "How To", "Misc"], &(&1 == category)) || :infinity
    end)
    |> Enum.map(fn {category, guides} ->
      {category, Enum.sort_by(guides, & &1.order)}
    end)
  end

  defp get_extensions(libraries) do
    Enum.flat_map(libraries, fn library ->
      library.versions
      |> Enum.find(&Ash.Resource.Info.loaded?(&1, :extensions))
      |> case do
        nil ->
          []

        %{extensions: extensions} ->
          extensions
      end
    end)
  end
end
