defmodule AshHqWeb.Components.CatalogueModal do
  @moduledoc "The library catalogue modal"
  use Surface.Component

  alias AshHqWeb.Components.Catalogue

  prop(id, :string, required: true)
  prop(libraries, :list, required: true)
  prop(selected_versions, :map, required: true)
  prop(change_versions, :event, required: true)
  prop(show_catalogue_call_to_action, :boolean)

  def render(assigns) do
    ~F"""
    <div
      id={@id}
      style="display: none;"
      class="fixed flex justify-center align-middle w-screen h-full backdrop-blur-sm bg-white bg-opacity-10 z-50"
    >
      <div
        :on-click-away={AshHqWeb.AppViewLive.toggle_catalogue()}
        class="dark:text-white absolute rounded-xl left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 w-3/4 max-w-[1200px] h-3/4 bg-white dark:bg-base-dark-850 border-2 dark:border-base-dark-900"
      >
        <Catalogue
          id={"#{@id}-contents"}
          libraries={@libraries}
          selected_versions={@selected_versions}
          change_versions={@change_versions}
          show_catalogue_call_to_action={@show_catalogue_call_to_action}
        />
      </div>
    </div>
    """
  end
end
