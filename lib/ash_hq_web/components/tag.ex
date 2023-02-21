defmodule AshHqWeb.Components.Tag do
  @moduledoc "Renders a simple pill style tag"
  use Surface.Component

  import AshHqWeb.Tails

  prop color, :atom, values: [:red, :blue]
  prop class, :string
  slot default

  def render(assigns) do
    ~F"""
    <div class={classes([
      [
        "flex flex-row flex-wrap contents-center px-2 py-1 text-xs font-medium rounded-full h-6 w-min",
        "bg-red-300 text-black": @color == :red,
        "bg-blue-300 text-black": @color == :blue
      ],
      @class
    ])}>
      <#slot />
    </div>
    """
  end
end
