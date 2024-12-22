defmodule AshHqWeb.Components.Blog.Tag do
  @moduledoc "Renders a pill-style tag"
  use Phoenix.Component

  attr :tag, :string, required: true
  attr :prefix, :string

  def tag(assigns) do
    ~H"""
    <.link
      href={"#{@prefix}?tag=#{@tag}"}
      class="dark:bg-gray-700 bg-gray-300 rounded-lg px-2 text-lg max-w-min whitespace-nowrap"
    >
      {@tag}
    </.link>
    """
  end
end
