defmodule AshHqWeb.Components.TreeView do
  @moduledoc """
  A tree view with collapsable nodes.

  The component must be supplied with a list of `%Item{}` structs defining
  the behaviour of each node in the tree.
  """

  use Surface.Component
  alias Phoenix.LiveView.JS
  alias AshHqWeb.Components.TreeView.Item

  @doc "DOM id for the outer div"
  prop id, :string, required: true

  @doc "Any additional CSS classes to add to the outer div"
  prop class, :css_class

  @doc "`TreeView.Item` nodes to display"
  slot default

  def render(assigns) do
    ~F"""
    <div id={@id} class={"py-3 px-3", @class}>
      <ul class="space-y-4">
        <#slot
          :for={item <- @default}
          context_put={Item, path: @id}
          {item}
        />
      </ul>
    </div>
    """
  end

  defmodule Item do
    @moduledoc """
    Data for an item in the TreeView.
    """

    use Surface.Component
    alias __MODULE__

    prop path, :string, from_context: {Item, :path}

    @doc "Logical name for the tree view item. Combined with the parent path to build the DOM id."
    prop name, :string, default: nil

    @doc "Text to display for the item."
    prop text, :string, default: ""

    @doc "Optional icon to display beside text"
    prop icon, :any

    @doc "Event handler to run when item clicked, eg JS.patch(~p'/some/path')"
    prop on_click, :event, default: %JS{}

    @doc "When true, allows the item's children to be hidden with a chevron icon."
    prop collapsable, :boolean, default: false

    @doc "The initial collapsed state of the children items."
    prop collapsed, :boolean, default: false

    @doc "The initial selection state of the item."
    prop selected, :boolean, default: false

    @doc "When true, displays an indentation guide to align deeply nested items."
    prop indent_guide, :boolean, default: false

    @doc "Any additional classes to add to the `<li>` element for the item."
    prop class, :css_class, default: nil

    @doc "Children `TreeView.Item` nodes."
    slot default

    def render(assigns) do
      ~F"""
      <style>
        .collapsed+ul {
          @apply hidden;
        }
        .collapsed .chevron {
          @apply -rotate-90;
        }
        @media (prefers-reduced-motion: no-preference) {
          .chevron {
            @apply transition-transform duration-200;
          }
        }
        .indent-guide {
          @apply border-l pl-1 border-primary-light-600 border-opacity-30;
        }
      </style>
      <li class={@class, "pt-2": @collapsable, "indent-guide": @indent_guide}>
        <div
          id={"#{@path}-#{@name}"}
          class={
            "rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-700",
            "bg-base-light-300 dark:bg-base-dark-600": @selected,
            collapsed: @collapsed
          }
        >
          <button
            :on-click={@on_click |> handle_click("#{@path}-#{@name}", @collapsable)}
            class="flex flex-row items-center w-full"
          >
            <div :if={@collapsable && slot_assigned?(:default)} class="chevron">
              <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
            </div>
            {#if @icon}{@icon}{/if}
            <span class="ml-1">{@text}</span>
          </button>
        </div>
        <ul :if={slot_assigned?(:default)} class="pl-2">
          <#slot context_put={Item, path: "#{@path}-#{@name}"} :for={item <- @default} {item} />
        </ul>
      </li>
      """
    end

    defp handle_click(js, id, collapsable) do
      if collapsable,
        do: toggle_class(js, "collapsed", to: "##{id}"),
        else: js
    end

    defp toggle_class(js, class, to: selector) do
      js
      |> JS.add_class(class, to: "#{selector}:not(.#{class})")
      |> JS.remove_class(class, to: "#{selector}.#{class}")
    end
  end
end
