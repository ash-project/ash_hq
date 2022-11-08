defmodule AshHqWeb.Components.TreeView do
  @moduledoc """
  A tree view with collapsable nodes.

  The component must be supplied with a list of `%Item{}` structs defining
  the behaviour of each node in the tree.
  """

  use Surface.Component
  alias Phoenix.LiveView.JS

  defmodule Item do
    @moduledoc """
    Data for an item in the TreeView.

    name: required - logical name for the tree view item. Used to build the DOM id.
    label: text to display for the item.
    link: props to forward to the `<.link/>` component, eg `[patch: ~p"/documents/123"]`
    items: child items
    icon: name prop to pass to the TreeView's render_icon component
    collapsable: when true, allows the item's children to be hidden
    collapsed: the initial collapsed state of the children items list
    selected: the initial selection state of the item
    indent_guide: When true, displays an indentation guide to align deeply nested items
    class: any additional classes to add to the `<li>` element for the item
    """
    defstruct name: nil,
              label: "",
              link: nil,
              items: nil,
              icon: nil,
              collapsable: false,
              collapsed: false,
              selected: false,
              indent_guide: false,
              class: nil

    def has_children?(%{items: items}), do: items not in [nil, []]
  end

  @doc "DOM id for the outer div"
  prop id, :string, required: true

  @doc "Items to display in the TreeView"
  prop items, :list, required: true

  @doc "A function component accepting props for `name` and `class`"
  prop render_icon, :any, required: true

  @doc "Any additional CSS classes to add to the outer div"
  prop class, :css_class

  def render(assigns) do
    ~F"""
    <style>
      .treeview :deep(.selected) {
      @apply bg-base-light-300;
      }
      :global(.dark) .treeview :deep(.selected) {
      @apply bg-base-dark-600;
      }
    </style>
    <div id={@id} class={"treeview py-3 px-3", @class}>
      <ul class="space-y-4">
        <li :for={item <- @items} class={item.class}>
          <.item item={item} path={@id} render_icon={@render_icon} root={@id} />
        </li>
      </ul>
    </div>
    """
  end

  defp item(%{item: %Item{}} = assigns) do
    ~F"""
    <div
      id={"#{@path}-#{@item.name}"}
      class={
        "rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-700",
        selected: @item.selected
      }
    >
      <.item_button item={@item} path={@path} render_icon={@render_icon} root={@root} />
    </div>
    <ul
      :if={Item.has_children?(@item)}
      id={"#{@path}-#{@item.name}-items"}
      class={"pl-2", hidden: @item.collapsed}
    >
      <li :for={item <- @item.items}
        class={
          item.class,
          "pt-2": Item.has_children?(item),
          "border-l pl-1 border-primary-light-600 border-opacity-30": @item.indent_guide
        }
      >
        <.item item={item} path={"#{@path}-#{@item.name}"} render_icon={@render_icon} root={@root} />
      </li>
    </ul>
    """
  end

  defp item_button(assigns) do
    ~F"""
    <button
      phx-click={maybe_collapse(@item, @path) |> maybe_link(@item, @path, @root)}
      class="flex flex-row items-center w-full"
    >
      <.chevron item={@item} path={@path} />
      <.icon item={@item} render_icon={@render_icon} />
      <span class="ml-1">{@item.label}</span>
    </button>
    """
  end

  defp chevron(assigns) do
    ~F"""
    <div
      :if={@item.collapsable}
      id={"#{@path}-#{@item.name}-chevron"}
      class={
        "motion-safe:transition-transform motion-safe:duration-200",
        "-rotate-90": @item.collapsed
      }
    >
      <Heroicons.Outline.ChevronDownIcon class="w-3 h-3 mr-1" />
    </div>
    """
  end

  defp icon(assigns) do
    ~F"""
    {#if @item.icon}
      {@render_icon.(assign(assigns, name: @item.icon, class: "w-4 h-4 flex-none"))}
    {/if}
    """
  end

  defp maybe_collapse(js \\ %JS{}, item, path) do
    if item.collapsable,
      do: toggle_collapsed(js, "#{path}-#{item.name}"),
      else: js
  end

  defp maybe_link(js, %{link: nil}, _path, _root), do: js

  defp maybe_link(js, item, path, root) do
    cond do
      Keyword.has_key?(item.link, :patch) -> JS.patch(js, item.link[:patch])
      Keyword.has_key?(item.link, :navigate) -> JS.navigate(js, item.link[:navigate])
    end
    |> update_selection("#{path}-#{item.name}", root)
  end

  defp toggle_collapsed(js, id) do
    js
    |> toggle_class("hidden", to: "##{id}-items")
    |> toggle_class("-rotate-90", to: "##{id}-chevron")
  end

  defp toggle_class(js, class, to: selector) do
    classes =
      class
      |> String.split(" ")
      |> Enum.map(&String.replace(&1, ":", "\\:"))
      |> Enum.map(fn class -> ".#{class}" end)

    js
    |> JS.add_class(class, to: "#{selector}:not(#{Enum.join(classes, ", ")})")
    |> JS.remove_class(class, to: "#{selector}#{Enum.join(classes, "")}")
  end

  defp update_selection(js, id, root) do
    js
    |> JS.add_class("selected", to: "##{id}")
    |> JS.remove_class("selected", to: "##{root} .selected")
  end
end
