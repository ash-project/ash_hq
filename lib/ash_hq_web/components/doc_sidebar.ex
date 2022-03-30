defmodule AshHqWeb.Components.DocSidebar do
  use Surface.Component

  alias AshHqWeb.Routes
  alias Surface.Components.LivePatch

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
  prop function, :any, required: true

  def render(assigns) do
    ~F"""
    <aside id={@id} class={"w-64 h-full block overflow-y-scroll", @class} aria-label="Sidebar">
      <div class="overflow-y-auto py-4 px-3">
        <ul class="space-y-2">
          {#for library <- @libraries}
            <li>
              <LivePatch
                to={Routes.library_link(library, selected_version_name(library, @selected_versions))}
                class={
                  "flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700",
                  "dark:bg-gray-600": !@module && !@guide && !@extension && @library && library.id == @library.id
                }
              >
                <Heroicons.Outline.CollectionIcon class="w-6 h-6" />
                <span class="ml-3 mr-2">{library.display_name}</span>
                <span class="font-light text-gray-500">{selected_version_name(library, @selected_versions)}</span>
              </LivePatch>
              {#if @library && @library_version && library.id == @library.id}
                {#if !Enum.empty?(@library_version.guides)}
                  <div class="ml-2 text-gray-500">
                    Guides
                  </div>
                {/if}
                {#for guide <- @library_version.guides}
                  <li class="ml-3">
                    <LivePatch
                      to={Routes.guide_link(
                        library,
                        selected_version_name(library, @selected_versions),
                        guide.url_safe_name
                      )}
                      class={
                        "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                        "dark:bg-gray-600": @guide && @guide.id == guide.id
                      }
                    >
                      <Heroicons.Outline.BookOpenIcon class="h-4 w-4" />
                      <span class="ml-3 mr-2">{guide.name}</span>
                    </LivePatch>
                  </li>
                {/for}

                {#if !Enum.empty?(@library_version.guides)}
                  <div class="ml-2 text-gray-500">
                    Extensions
                  </div>
                {/if}
                {#for extension <- get_extensions(library, @selected_versions)}
                  <li class="ml-3">
                    <LivePatch
                      to={Routes.extension_link(library, selected_version_name(library, @selected_versions), extension.name)}
                      class={
                        "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                        "dark:bg-gray-600": @extension && @extension.id == extension.id
                      }
                    >
                      <span class="ml-3 mr-2">{extension.name}</span>
                      {render_icon(assigns, extension.type)}
                    </LivePatch>
                    {#if @extension && @extension.id == extension.id && !Enum.empty?(extension.dsls)}
                      {render_dsls(assigns, extension.dsls, [])}
                    {/if}
                  </li>
                {/for}
                {#if !Enum.empty?(@library_version.modules)}
                  <div class="ml-2 text-gray-500">
                    Modules
                  </div>
                  {#for module <- @library_version.modules}
                    <li class="ml-3">
                      <LivePatch
                        to={Routes.module_link(library, @library_version.version, module.name)}
                        class={
                          "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                          "dark:bg-gray-600": !@function && @module && @module.id == module.id
                        }
                      >
                        <span class="ml-3 mr-2">{module.name}</span>
                        <Heroicons.Outline.CodeIcon class="h-4 w-4" />
                      </LivePatch>
                      {#if @module && @module.id == module.id}
                        <ul>
                        {#for function <- @module.functions}
                          <li class="border-l pl-1 border-orange-600 border-opacity-30">
                            <LivePatch
                              to={Routes.function_link(library, @library_version.version, module.name, function.name, function.arity)}
                              class={
                                "flex items-center p-1 text-base font-normal rounded-lg hover:text-orange-300",
                                "text-orange-600 dark:text-orange-400 font-bold": @function && @function.id == function.id
                              }
                            >
                              {function.name}/{function.arity}
                            </LivePatch>
                          </li>
                        {/for}

                        </ul>
                      {/if}
                    </li>
                  {/for}
                {/if}
              {/if}
            </li>
          {/for}
        </ul>
      </div>
    </aside>
    """
  end

  defp render_dsls(assigns, dsls, path) do
    ~F"""
    <ul class={"ml-1 flex flex-col"}>
      {#for dsl <- Enum.filter(dsls, &(&1.path == path))}
        <li class="border-l pl-1 border-orange-600 border-opacity-30">
          <LivePatch
            to={Routes.dsl_link(@library, @library_version.version, @extension.name, dsl)}
            class={
              "flex items-center p-1 text-base font-normal rounded-lg hover:text-orange-300",
              "text-orange-600 dark:text-orange-400 font-bold": @dsl && @dsl.id == dsl.id
            }
          >
            {dsl.name}
          </LivePatch>
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

  defp selected_version_name(library, selected_versions) do
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
end
