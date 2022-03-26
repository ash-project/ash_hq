defmodule AshHqWeb.Components.CodeExample do
  use Surface.LiveComponent

  prop text, :string, required: true
  prop class, :css_class
  prop title, :string
  prop start_collapsed, :boolean, default: false
  prop collapsable, :boolean, default: false

  data collapsed, :string, default: false

  def render(assigns) do
    ~F"""
    <div class={"rounded-xl bg-primary-black border border-gray-400 text-sm border-b", @class}>
      <div class={"flex flex-row justify-between py-2 pl-2 pr-8", "border-b border-gray-600": !@collapsed}>
        <div class="flex flex-row justify-start space-x-1">
          <div class="w-3 h-3 bg-gray-600 rounded-full" />
          <div class="w-3 h-3 bg-gray-600 rounded-full" />
          <div class="w-3 h-3 bg-gray-600 rounded-full" />
        </div>
        {#if @title}
          <div class="justify-self-end text-white">{@title}</div>
          <div>
            {#if @collapsable}
              <button class="hover:bg-gray-700" :on-click="fold">
                {#if @collapsed}
                  <Heroicons.Solid.ChevronDoubleDownIcon class="w-4 h-4" />
                {#else}
                  <Heroicons.Solid.ChevronDoubleUpIcon class="w-4 h-4" />
                {/if}
              </button>
            {/if}
          </div>
        {/if}
      </div>
      <div class={"pl-1 pt-2", "h-0": @collapsed}>
      <div class="flex flex-row">
        <div class="flex flex-col border-r border-gray-700 pr-1">
          {#for {line, no} <- to_code(@text)}
            <pre>{no}</pre>
          {/for}
        </div>
        <div>
          {#for {line, no} <- to_code(@text)}
            <div class={"flex flex-row font-code mr-4", "invisible h-0": @collapsed}>
              <div class="sm:hidden md:block mr-8 text-gray-600"></div>{Phoenix.HTML.raw(line)}
            </div>
          {/for}
        </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("fold", _, socket) do
    {:noreply, assign(socket, :collapsed, !socket.assigns.collapsed)}
  end

  def update(assigns, socket) do
    if assigns.start_collapsed && assigns.collapsable do
      {:ok, socket |> assign(assigns) |> assign(:collapsed, true)}
    else
      {:ok, socket |> assign(assigns) |> assign(:collapsed, false)}
    end
  end

  defp to_code(text) do
    # TODO: do this at compile time
    lines =
      text
      # this is pretty naive, won't handle things like block comments
      |> String.split("\n")
      |> Enum.reverse()
      |> Enum.drop_while(&(&1 in [""]))
      |> Enum.reverse()
      |> Enum.map(fn
        "" ->
          "<br>"

        line ->
          Makeup.highlight(line)
      end)

    count = Enum.count(lines)

    padding = String.length(to_string(count))

    lines
    |> Enum.with_index()
    |> Enum.map(fn {line, index} ->
      {line, String.pad_leading(to_string(index + 1), padding, " ")}
    end)
  end
end
