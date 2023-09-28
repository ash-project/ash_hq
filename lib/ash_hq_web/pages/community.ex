defmodule AshHqWeb.Pages.Community do
  @moduledoc "The Community page - a spot to collect the various links to different Ash community hubs that exist around the web."

  use Surface.LiveComponent

  def render(assigns) do
    ~F"""
    <div>
      Hello World
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end
end
