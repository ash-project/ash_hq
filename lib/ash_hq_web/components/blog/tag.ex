defmodule AshHqWeb.Components.Blog.Tag do
  @moduledoc "Renders a pill-style tag"
  use Surface.Component

  alias Surface.Components.LivePatch

  prop tag, :string, required: true

  def render(assigns) do
    ~F"""
    <LivePatch
      to={"/blog?tag=#{@tag}"}
      class="dark:bg-gray-700 bg-gray-300 rounded-lg px-2 text-lg max-w-min"
    >
      {@tag}
    </LivePatch>
    """
  end
end
