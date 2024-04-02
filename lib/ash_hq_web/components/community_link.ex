defmodule AshHqWeb.Components.CommunityLink do
  @moduledoc "A component for rendering a link for the Community page."
  use Phoenix.Component

  import AshHqWeb.Tails

  attr :name, :string, required: true
  attr :class, :string, default: nil
  attr :url, :string, required: true

  slot :icon
  slot :description

  def link(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <div class={classes(["w-16 h-16 text-primary-light-600 dark:text-primary-dark-400", @class])}>
        <%= render_slot(@icon) %>
      </div>
      <a
        href={@url}
        class="font-bold text-3xl mt-4 hover:underline flex flex-row items-center space-x-2"
      >
        <span><%= @name %></span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-6 h-6"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25"
          />
        </svg>
      </a>
      <div class="text-xl mt-4">
        <%= render_slot(@description) %>
      </div>
    </div>
    """
  end
end
