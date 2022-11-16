defmodule AshHqWeb.Components.Catalogue do
  @moduledoc "Renders the catalogue of available packages"
  use Surface.Component

  alias AshHqWeb.Components.CalloutText
  alias Surface.Components.Form
  alias Surface.Components.Form.Select

  prop id, :string, required: true
  prop libraries, :list, required: true
  prop selected_versions, :map, required: true
  prop change_versions, :event, required: true
  prop toggle, :any

  def render(assigns) do
    ~F"""
    <div id={@id} class="w-full h-full overflow-y-auto">
      <div class="w-full flex justify-between text-center mb-6 text-xl mt-1">
        <div />
        <CalloutText text="Ash Libraries" />
        <div>
          {#if @toggle}
            <button id="close-search-versions" phx-click={@toggle}>
              <Heroicons.Solid.XIcon class="h-4 w-4" />
            </button>
          {/if}
        </div>
      </div>
      <Form for={:selected_versions} change={@change_versions} class="flex flex-wrap gap-4 m-4">
        {#for library <- Enum.sort_by(@libraries, & &1.order)}
          <div class="bg-base-light-200 dark:bg-base-dark-700 p-2 rounded-lg flex-grow">
            <div class="flex justify-between items-center my-1">
              <div class="font-bold text-xl">
                <CalloutText text={library.display_name} />
              </div>
              <div>
                <Select
                  class="rounded-lg text-black"
                  name={"versions[#{library.id}]"}
                  id={"#{@id}-selected_versions-#{library.id}"}
                  selected={value(@selected_versions, library.id)}
                  options={[{"Hidden", nil}, {"Latest", "latest"}] ++
                    (library.versions
                     |> Enum.sort(&(Version.compare(&1.version, &2.version) != :lt))
                     |> Enum.map(fn version ->
                       {version.version, version.id}
                     end))}
                /></div>
            </div>
            <div class="max-w-xs">
              {library.description}
            </div>
          </div>
        {/for}
      </Form>
    </div>
    """
  end

  defp value(selected_versions, library_id) do
    case selected_versions[library_id] do
      nil -> nil
      "" -> nil
      value -> value
    end
  end
end
