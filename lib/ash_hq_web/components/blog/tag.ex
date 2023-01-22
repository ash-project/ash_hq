defmodule AshHqWeb.Components.Blog.Tag do
  @moduledoc "Renders a pill-style tag"
  use Surface.Component

  alias Surface.Components.LivePatch

  prop tag, :string, required: true
  prop prefix, :string

  def render(assigns) do
    ~F"""
    <LivePatch
      to={"#{@prefix}?tag=#{@tag}"}
      class="dark:bg-gray-700 bg-gray-300 rounded-lg px-2 text-lg max-w-min whitespace-nowrap"
    >
      {@tag}
    </LivePatch>
    """
  end
end
