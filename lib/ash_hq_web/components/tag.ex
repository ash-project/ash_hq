defmodule AshHqWeb.Components.Tag do
  @moduledoc "Renders a simple pill style tag"
  use Surface.Component

  prop color, :atom, values: [:red]
  slot default

  def render(assigns) do
    ~F"""
    <div class={
      "flex flex-row flex-wrap contents-center px-2 py-1 text-xs font-medium rounded-full",
      "bg-red-300 text-black": @color == :red
    }>
      <#slot />
    </div>
    """
  end
end
