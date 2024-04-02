defmodule AshHqWeb.Components.CalloutText do
  @moduledoc "Highlights some text on the page"
  use Phoenix.Component

  import AshHqWeb.Tails

  attr :text, :string, required: true
  attr :class, :any, default: ""

  def callout(assigns) do
    ~H"""
    <span class={classes(["text-primary-light-600 dark:text-primary-dark-400 font-bold", @class])}>
      <%= @text %>
    </span>
    """
  end
end
