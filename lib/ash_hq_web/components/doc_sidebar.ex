defmodule AshHqWeb.Components.DocSidebar do
  use Surface.Component

  alias AshHqWeb.Routes
  alias Surface.Components.LiveRedirect

  prop class, :css_class, default: ""
  prop libraries, :list, required: true
  prop extension, :any, default: nil
  prop guide, :any, default: nil
  prop library, :any, default: nil
  prop library_version, :any, default: nil
  prop selected_versions, :map, default: %{}
  prop id, :string, required: true

  def render(assigns) do
    ~F"""
    <aside id={@id} class={"w-64 h-full block", @class} aria-label="Sidebar">
      <div class="overflow-y-auto py-4 px-3">
        <ul class="space-y-2">
          {#for library <- @libraries}
            <li>
              <LiveRedirect
                to={Routes.library_link(library, selected_version_name(library, @selected_versions))}
                class={
                  "flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700",
                  "dark:bg-gray-600": !@guide && !@extension && @library && library.id == @library.id
                }
              >
                <Heroicons.Outline.CollectionIcon class="w-6 h-6" />
                <span class="ml-3 mr-2">{library.display_name}</span>
                <span class="font-light text-gray-500">{selected_version_name(library, @selected_versions)}</span>
              </LiveRedirect>
              {#if @library && @library_version && library.id == @library.id}
                {#if !Enum.empty?(@library_version.guides)}
                  <div class="ml-2 text-gray-500">
                    Guides
                  </div>
                {/if}
                {#for guide <- @library_version.guides}
                  <li class="ml-3">
                    <LiveRedirect
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
                    </LiveRedirect>
                  </li>
                {/for}

                {#if !Enum.empty?(@library_version.guides)}
                  <div class="ml-2 text-gray-500">
                    Extensions
                  </div>
                {/if}
                {#for extension <- get_extensions(library, @selected_versions)}
                  <li class="ml-3">
                    <LiveRedirect
                      to={Routes.extension_link(library, selected_version_name(library, @selected_versions), extension.name)}
                      class={
                        "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                        "dark:bg-gray-600": @extension && @extension.id == extension.id
                      }
                    >
                      {render_icon(assigns, extension.type)}
                      <span class="ml-3 mr-2">{extension.name}</span>
                    </LiveRedirect>
                  </li>
                {/for}
              {/if}
            </li>
          {/for}
        </ul>
      </div>
    </aside>
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
