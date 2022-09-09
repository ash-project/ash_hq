defmodule AshHqWeb.Components.CalloutText do
  @moduledoc "Highlights some text on the page"
  use Surface.Component

  import AshHq.Colors

  prop text, :string, required: true

  def render(%{__context__: %{platform: :ios}} = assigns) do
    ~F"""
    <text color={primary_light_600()}>{@text}</text>
    """
  end

  def render(assigns) do
    ~F"""
    <span class="text-primary-light-600 dark:text-primary-dark-400 font-bold">
      {@text}
    </span>
    """
  end
end
