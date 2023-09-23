defmodule AshHqWeb.Components.VersionPills do
  @moduledoc "Renders pills for selected versions"
  use Surface.LiveComponent

  prop selected_versions, :map, default: %{}
  prop libraries, :list, default: []
  prop add_version, :event
  prop remove_version, :event
  prop change_version, :event
  prop editable, :boolean, default: true
  prop toggle, :event

  data adding_version, :boolean, default: false

  def render(assigns) do
    ~F"""
    <div class="flex flex-row flex-wrap align-center items-center ml-2 justify-start gap-2 flex-grow">
      {#for library <- @libraries}
        {#if @selected_versions[library.id] not in [nil, ""]}
          <div class="flex flex-row flex-wrap contents-center items-center ml-1 px-2 py-1 bg-primary-light-500 dark:bg-primary-dark-300 hover:bg-primary-light-600 hover:dark:bg-primary-dark-400 text-black text-xs font-medium rounded-full">
            {library.name}{#if selected_version(library, @selected_versions[library.id]) != "latest"}
              | {selected_version(library, @selected_versions[library.id])}
            {/if}
            {#if @editable}
              <button
                :on-click={@remove_version}
                phx-value-library={library.id}
                class="flex items-center w-6 h-6"
              ><Heroicons.Outline.XIcon class="h-4 w-4 ml-1" /></button>
            {/if}
          </div>
        {/if}
      {/for}
      {#if @editable}
        {#if @toggle}
          <button :on-click={@toggle}>
            <Heroicons.Solid.PlusIcon class="h-4 w-4" />
          </button>
        {#else}
          <button phx-click={AshHqWeb.AppViewLive.toggle_catalogue()}>
            <Heroicons.Solid.PlusIcon class="h-4 w-4" />
          </button>
        {/if}
      {/if}
    </div>
    """
  end

  def update(assigns, socket) do
    case assigns[:action] do
      :close_add_version ->
        {:ok, assign(socket, :adding_version, false)}

      _ ->
        {:ok, assign(socket, assigns)}
    end
  end

  defp selected_version(library, selected_version) do
    if selected_version == "latest" do
      "latest"
    else
      Enum.find(library.versions, &(&1.id == selected_version)).version
    end
  end

  def handle_event("add-version", _, socket) do
    {:noreply, assign(socket, :adding_version, true)}
  end
end
