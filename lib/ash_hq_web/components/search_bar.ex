defmodule AshHqWeb.Components.SearchBar do
  @moduledoc "A clickable search bar that brings up the search overlay"
  use Phoenix.Component

  import Tails

  attr :class, :any, default: ""
  attr :device_brand, :string

  def search_bar(assigns) do
    ~H"""
    <button
      class={
        classes([
          "w-96 button border border-base-light-400 bg-base-light-200 dark:border-base-dark-700 rounded-lg dark:bg-base-dark-700 hover:bg-base-light-300 dark:hover:bg-base-dark-600",
          @class
        ])
      }
      phx-click={AshHqWeb.AppViewLive.toggle_search()}
    >
      <div class="flex flex-row justify-between items-center px-4">
        <div class="h-12 flex flex-row justify-start items-center text-center space-x-4">
          <span class="hero-magnifying-glass w-4 h-4" />
          <div>Search Documentation</div>
        </div>
        <div>⌘ + K</div>
      </div>
    </button>
    """
  end
end
