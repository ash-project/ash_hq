defmodule AshHqWeb.Components.CodeExample do
  @moduledoc """
  Renders a code example, as seen on the home page

  This is so stupid. Why is this a live component
  """
  use Phoenix.LiveComponent
  import AshHqWeb.Tails

  attr :code, :string, required: true
  attr :class, :any
  attr :title, :string
  attr :start_collapsed, :boolean, default: false
  attr :collapsible, :boolean, default: false

  def render(assigns) do
    ~H"""
    <div class={classes([

      "rounded-xl bg-[#f3f4f6] dark:bg-[#22242D] border border-base-light-400 dark:border-base-dark-700 text-sm border-b",
      @class
    ])
    }>
    <%= if @collapsible do %>
        <button
          type="button"
          phx-click="fold"
          phx-target={@myself}
          class={
          classes([

            "flex flex-row rounded-t-xl w-full justify-between py-2 pl-2 pr-8 hover:bg-base-light-500 dark:hover:border-base-dark-600",
            "border-base-light-400 dark:border-base-dark-700 border-b": !@collapsed
          ])
          }
        >
          <div class="flex flex-row justify-start space-x-1">
            <div class="w-3 h-3 bg-base-light-600 rounded-full" />
            <div class="w-3 h-3 bg-base-light-600 rounded-full" />
            <div class="w-3 h-3 bg-base-light-600 rounded-full" />
          </div>
          <%= if @title do %>
            <h3 class="justify-self-end text-base-light-700 dark:text-white"><%= @title %></h3>
            <div>
              <%= if @collapsible do %>
                <%= if @collapsed do %>
                  <span class="hero-chevron-double-down-solid w-4 h-4"/>
                <% else %>
                  <span class="hero-chevron-double-up-solid w-4 h-4"/>
                <% end %>
              <% end %>
            </div>
          <% end %>
        </button>
    <% else %>
        <div class={classes([
          "flex flex-row justify-between py-2 pl-2 pr-8",
          "border-base-light-400 dark:border-base-dark-700 border-b": !@collapsed
        ])
        }>
          <div class="flex flex-row justify-start space-x-1 w-full">
            <div class="w-3 h-3 bg-base-light-600 rounded-full" />
            <div class="w-3 h-3 bg-base-light-600 rounded-full" />
            <div class="w-3 h-3 bg-base-light-600 rounded-full" />
            <div class="flex grow justify-center">
          <%= if @title do %>
            <h3 class="items-center text-base-light-700 dark:text-white"><%= @title %></h3>
          <% end %>
          </div>
          </div>
        </div>
      <% end %>
      <div class={classes(["pl-1 py-2", hidden: @collapsed])}>
        <div class="flex flex-row overflow-auto">
          <div class="flex flex-col border-r text-base-light-500 dark:text-white border-base-light-400 dark:border-base-dark-700 pr-1">
            <%= if !@collapsed do %>
              <%= for {_line, no} <- @code do %>
                <pre><%= no %></pre>
              <% end %>
              <% else %>
              <div class="invisible h-0">{to_string(List.last(@code) |> elem(0))}</div>
            <% end %>
          </div>
          <div>
            <%= for {line, _no} <- @code do %>
              <div class={classes(["flex flex-row mr-4", "invisible h-0": @collapsed])}>
                <div class="sm:hidden md:block mr-8 text-base-light-600 font-mono" /><%= Phoenix.HTML.raw(line) %>
              </div>
            <% end %>
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
    if assigns[:start_collapsed] && assigns.collapsible do
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
