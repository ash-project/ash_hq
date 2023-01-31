defmodule AshHqWeb.Components.Catalogue do
  @moduledoc "Renders the catalogue of available packages"
  use Surface.Component

  alias Surface.Components.Form
  alias Surface.Components.Form.Select

  prop(id, :string, required: true)
  prop(libraries, :list, required: true)
  prop(selected_versions, :map, required: true)
  prop(change_versions, :event, required: true)
  prop(toggle, :any)
  prop(show_catalogue_call_to_action, :boolean, default: false)

  def render(assigns) do
    ~F"""
    <div id={@id} class="w-full h-full overflow-y-auto p-6">
      <div class="w-full flex justify-between">
        <p class="text-xl font-bold">Select Ash libraries</p>
        {#if @toggle}
          <button id="close-search-versions" phx-click={@toggle} class="">
            <Heroicons.Solid.XIcon class="h-6 w-6" />
          </button>
        {/if}
      </div>
      <div
        :if={@show_catalogue_call_to_action}
        class="text-sm my-2 text-base-light-700 dark:text-base-dark-50"
      >
        <Heroicons.Outline.ExclamationCircleIcon class="h-4 w-4 inline-block mb-0.5" />
        You can see this screen at any time by pressing <Heroicons.Solid.PlusIcon class="h-4 w-4 inline-block mb-0.5" /> next to the list of included packages in the sidebar
      </div>
      <Form for={:selected_versions} change={@change_versions} class="lg:grid lg:grid-cols-2">
        {#for library <- Enum.sort_by(@libraries, & &1.order)}
          <div class="py-6 lg:p-6 lg:even:pl-0 lg:odd:pr-0 flex-grow border-b border-base-light-300 dark:border-base-dark-600">
            <div class="flex justify-between items-center mb-1">
              <div class={[
                "font-bold text-lg",
                "text-primary-light-600 dark:text-primary-dark-400": value(@selected_versions, library.id),
                "text-base-light-500 dark:text-base-dark-300": !value(@selected_versions, library.id)
              ]}>{library.display_name}</div>
              <Select
                class="rounded-lg text-black dark:bg-base-dark-700 dark:text-white dark:border-0"
                name={"versions[#{library.id}]"}
                id={"#{@id}-selected_versions-#{library.id}"}
                selected={value(@selected_versions, library.id)}
                options={[{"hidden", nil}] ++ formatted_versions(library.versions)}
              />
            </div>
            {library.description}
          </div>
        {/for}
      </Form>

      <p class="mt-6">... and more coming soon! <img class="h-6 w-6 inline-block" src="/images/ash-logo.png"></p>
    </div>
    """
  end

  defp formatted_versions(versions) do
    [{latest, _} | rest] =
      versions
      |> Enum.sort(&(Version.compare(&1.version, &2.version) != :lt))
      |> Enum.map(fn version ->
        {version.version, version.id}
      end)

    [{"#{latest} (latest)", "latest"} | rest]
  end

  defp value(selected_versions, library_id) do
    case selected_versions[library_id] do
      nil -> nil
      "" -> nil
      value -> value
    end
  end
end
