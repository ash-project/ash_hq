defmodule AshHqWeb.Components.CalloutText do
  @moduledoc "Highlights some text on the page"
  use Surface.Component

  import AshHqWeb.Tails

  prop text, :string, required: true
  prop class, :css_class

  def render(assigns) do
    ~F"""
    <span class={classes(["text-primary-light-600 dark:text-primary-dark-400 font-bold", @class])}>
      {@text}
    </span>
    """
  end
end
