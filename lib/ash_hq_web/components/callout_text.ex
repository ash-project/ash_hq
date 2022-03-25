defmodule AshHqWeb.Components.CalloutText do
  use Surface.Component

  slot default, required: true

  def render(assigns) do
    ~F"""
    <span class="text-orange-600 dark:text-orange-400 font-bold typed-out-container">
      <#slot />
    </span>
    """
  end
end
