defmodule AshHqWeb.Components.VersionPills do
  use Surface.LiveComponent

  alias Surface.Components.Form
  alias Surface.Components.Form.Select

  prop(selected_versions, :map, default: %{})
  prop(libraries, :list, default: [])
  prop(add_version, :event)
  prop(remove_version, :event)
  prop(change_version, :event)
  prop(editable, :boolean, default: true)

  data(adding_version, :boolean, default: false)

  def render(assigns) do
    ~F"""
    <div class="flex flex-row flex-wrap align-center items-center ml-2 justify-star gap-2 flex-grow">
      {#for library <- @libraries}
        {selected_version = @selected_versions[library.id]
        nil}
        {#if selected_version not in [nil, ""]}
          {version_name = selected_version(library, selected_version)
          nil}
          <div class="flex flex-row flex-wrap contents-center px-2 py-1 bg-primary-light-500 dark:bg-primary-light-400 hover:bg-primary-light-600 text-black text-xs font-medium rounded-full">
            {library.name}{#if version_name != "latest"}
              | {version_name}
            {/if}
            {#if @editable}
              <button :on-click={@remove_version} phx-value-library={library.id}><Heroicons.Outline.XIcon class="h-3 w-3 ml-1" /></button>
            {/if}
          </div>
        {/if}
      {/for}
      {#if @editable && can_be_added?(@selected_versions) && !@adding_version}
        <button :on-click="add-version">
          <Heroicons.Solid.PlusIcon class="h-4 w-4" />
        </button>
      {/if}
      {#if @adding_version}
        <Form for={:add_version} change={@add_version}>
          <Select
            class="rounded-lg"
            name={:library}
            options={packages_to_add(@libraries, @selected_versions)}
          />
        </Form>
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

  defp can_be_added?(selected_versions) do
    Enum.any?(selected_versions, fn {_, val} -> val in [nil, ""] end)
  end

  defp packages_to_add(libraries, selected_versions) do
    Enum.concat(
      [{"", ""}],
      libraries
      |> Enum.filter(&(selected_versions[&1.id] in [nil, ""]))
      |> Enum.map(&{&1.name, &1.id})
    )
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
