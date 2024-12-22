defmodule AshHqWeb.Components.Icon do
  @moduledoc """
  Defines icons for different types of resources.
  """
  use Phoenix.Component
  import Tails

  attr(:type, :string, required: true)
  attr(:classes, :string, required: false, default: "")

  def icon(assigns) do
    case assigns.type do
      type when type in ["Dsl", "DSL"] ->
        ~H"""
        <span class={classes(["hero-puzzle-piece", @classes])} />
        """

      "Forum" ->
        ~H"""
        <span class={classes(["hero-user-group", @classes])} />
        """

      type when type in ["Guide", "Guides"] ->
        ~H"""
        <span class={classes(["hero-book-open", @classes])} />
        """

      type when type in ["Mix Task", "Mix Tasks"] ->
        # Command-line icon
        ~H"""
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class={@classes}
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M6.75 7.5l3 2.25-3 2.25m4.5 0h3m-9 8.25h13.5A2.25 2.25 0 0021 18V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v12a2.25 2.25 0 002.25 2.25z"
          />
        </svg>
        """

      _default ->
        # Includes the Code category
        ~H"""
        <span class={classes(["hero-code-bracket", @classes])} />
        """
    end
  end
end
