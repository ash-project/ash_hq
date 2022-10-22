defmodule AshHqWeb.Components.CodeExample do
  @moduledoc "Renders a code example, as seen on the home page"
  use Surface.LiveComponent

  prop code, :string, required: true
  prop class, :css_class
  prop title, :string
  prop start_collapsed, :boolean, default: false
  prop collapsible, :boolean, default: false

  data collapsed, :string, default: false

  def render(assigns) do
    ~F"""
    <div class={
      "rounded-xl bg-silver-phoenix dark:bg-base-dark-800 border border-base-light-400 dark:border-base-dark-700 text-sm border-b",
      @class
    }>
      <div class={
        "flex flex-row justify-between py-2 pl-2 pr-8",
        "border-base-light-400 dark:border-base-dark-700 border-b": !@collapsed
      }>
        <div class="flex flex-row justify-start space-x-1">
          <div class="w-3 h-3 bg-base-light-600 rounded-full" />
          <div class="w-3 h-3 bg-base-light-600 rounded-full" />
          <div class="w-3 h-3 bg-base-light-600 rounded-full" />
        </div>
        {#if @title}
          <div class="justify-self-end text-base-light-700 dark:text-white">{@title}</div>
          <div>
            {#if @collapsible}
              <button class="hover:bg-base-light-400 dark:hover:bg-base-dark-700" :on-click="fold">
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
      <div class={"pl-1 py-2", hidden: @collapsed}>
        <div class="flex flex-row overflow-auto">
          <div class="flex flex-col border-r text-base-light-500 dark:text-white border-base-light-400 dark:border-base-dark-700 pr-1">
            {#if !@collapsed}
              {#for {_line, no} <- @code}
                <pre>{no}</pre>
              {/for}
            {#else}
              <div class="invisible h-0">{to_string(List.last(@code) |> elem(0))}</div>
            {/if}
          </div>
          <div>
            {#for {line, _no} <- @code}
              <div class={"flex flex-row mr-4", "invisible h-0": @collapsed}>
                <div class="sm:hidden md:block mr-8 text-base-light-600 font-mono" />{Phoenix.HTML.raw(line)}
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
    if assigns.start_collapsed && assigns.collapsible do
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:collapsed, true)}
    else
      {:ok,
       socket
       |> assign(assigns)
       |> assign(:collapsed, false)}
    end
  end

  @doc false
  def to_code(text) do
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
