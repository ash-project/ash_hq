defmodule AshHqWeb.Components.Icon do
  @moduledoc """
  Defines icons for different types of resources.
  """
  use Surface.Component

  prop(type, :string, required: true)
  prop(classes, :string, required: false, default: "")

  def render(assigns) do
    case assigns.type do
      type when type in ["Dsl", "DSL"] ->
        ~F"""
        <Heroicons.Outline.PuzzleIcon class={@classes} />
        """

      "Forum" ->
        ~F"""
        <Heroicons.Outline.UserGroupIcon class={@classes} />
        """

      type when type in ["Guide", "Guides"] ->
        ~F"""
        <Heroicons.Outline.BookOpenIcon class={@classes} />
        """

      type when type in ["Mix Task", "Mix Tasks"] ->
        # Command-line icon
        ~F"""
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
        ~F"""
        <Heroicons.Outline.CodeIcon class={@classes} />
        """
    end
  end
end
