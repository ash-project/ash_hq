defmodule AshHqWeb.Components.CalloutText do
  @moduledoc "Highlights some text on the page"
  use Surface.Component

  slot default, required: true

  def render(assigns) do
    ~F"""
    <span class="text-primary-light-600 dark:text-primary-dark-400 font-bold">
      <#slot />
    </span>
    """
  end
end
