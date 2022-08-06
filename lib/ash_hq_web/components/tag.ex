defmodule AshHqWeb.Components.Tag do
  @moduledoc "Renders a simple pill style tag"
  use Surface.Component

  prop color, :atom, values: [:red]
  slot default

  def render(assigns) do
    ~F"""
    <div class={"rounded-xl p-1 w-min", "bg-red-300 text-black": @color == :red}>
      <#slot />
    </div>
    """
  end
end
