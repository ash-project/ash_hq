defmodule AshHqWeb.Components.SearchBar do
  use Surface.Component

  prop class, :css_class, default: ""

  def render(assigns) do
    ~F"""
    <button
      class={
        "w-96 button border border-gray-400 bg-gray-200 dark:border-gray-700 rounded-lg dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600",
        @class
      }
      phx-click={AshHqWeb.AppViewLive.toggle_search()}
    >
      <div class="flex flex-row justify-between items-center px-4">
        <div class="h-12 flex flex-row justify-start items-center text-center space-x-4">
          <Heroicons.Outline.SearchIcon class="w-4 h-4" />
          <div>Search Documentation</div>
        </div>
        <div>⌘ K</div>
      </div>
    </button>
    """
  end
end
