defmodule AshHqWeb.Components.CalloutText do
  @moduledoc "Highlights some text on the page"
  use Surface.Component

  import AshHq.Classes

  prop text, :string, required: true
  prop class, :css_class

  def render(%{__context__: %{platform: :ios}} = assigns) do
    ~F"""
    <text color={primary_light_600()}>{@text}</text>
    """
  end

  def render(assigns) do
    ~F"""
    <span class={classes("text-primary-light-600 dark:text-primary-dark-400 font-bold", @class)}>
      {@text}
    </span>
    """
  end
end
