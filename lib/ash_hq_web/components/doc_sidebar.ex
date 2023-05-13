defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc """
  Renders the sidebar data, and uses `Phoenix.LiveView.JS` to manage selection/collapsible state.
  """
  use Surface.LiveComponent

  alias AshHqWeb.Components.{Icon, Search}
  alias Phoenix.LiveView.JS
  alias Surface.Components.LivePatch

  prop libraries, :any
  prop remove_version, :any
  prop selected_versions, :any
  prop class, :any
  prop sidebar_data, :any, default: []

  def render(assigns) do
    ~F"""
    <aside id={@id} class={"grid z-40 bg-white dark:bg-base-dark-850", @class} aria-label="Sidebar">
      <div class="flex flex-col px-1">
        <div class="text-black dark:text-white text-sm w-full px-2 mb-2">
          Including Libraries:
        </div>
        <AshHqWeb.Components.VersionPills
          id={"#{@id}-version-pills"}
          libraries={@libraries}
          remove_version={@remove_version}
          selected_versions={@selected_versions}
        />
        <ul class="ml-2 mt-4">
          {#for %{name: name, id: id, categories: categories} <- @sidebar_data}
            <li id={"#{@id}-#{id}"} class="mb-4">
              <button
                class="flex flex-row items-start w-full text-left rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-750"
                phx-click={collapse("#{@id}-#{id}")}
              >
                <div
                  class={"chevron mr-1.5 mt-1.5 origin-center", "rotate-[-90deg]": !has_active?(categories)}
                  id={"#{@id}-#{id}-chevron"}
                >
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3" />
                </div>
                {name}
              </button>
              <ul
                class="ml-4"
                id={"#{@id}-#{id}-contents"}
                style={if !has_active?(categories), do: "display: none", else: ""}
              >
                {#for %{name: item_name, to: to, id: item_id, active?: active?} <- categories}
                  {id = "#{@id}-#{id}-#{item_id}"
                  nil}
                  <li
                    id={id}
                    class={
                      "rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-750",
                      "bg-base-light-200 dark:bg-base-dark-700 active-sidebar-nav": active?
                    }
                  >
                    <LivePatch
                      to={to}
                      opts={phx_click: mark_active(id)}
                      class="flex flex-row items-start w-full text-left text-base-light-900 dark:text-base-dark-100"
                    >
                      <Icon type="DSL" classes="h-4 w-4 flex-none mt-1 mr-1.5" />
                      {item_name}
                    </LivePatch>
                  </li>
                {/for}
                {#for {category, items} <- categories}
                  <li class="pt-1 pl-0.5" id={"#{@id}-#{id}-#{slug(category)}"}>
                    <button
                      class="flex flex-row items-start w-full text-left rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-750"
                      phx-click={collapse("#{@id}-#{id}-#{slug(category)}")}
                    >
                      <div
                        class={"chevron mr-1.5 mt-1.5 origin-center", "rotate-[-90deg]": !has_active?(items)}
                        id={"#{@id}-#{id}-#{slug(category)}-chevron"}
                      >
                        <Heroicons.Outline.ChevronDownIcon class="w-3 h-3" />
                      </div>
                      <span class="text-base-light-500 dark:text-base-dark-300">{category}</span>
                    </button>

                    <ul
                      class="ml-4"
                      id={"#{@id}-#{id}-#{slug(category)}-contents"}
                      style={if !has_active?(items), do: "display: none", else: ""}
                    >
                      {#for {library, items} <- items}
                        <li class="pt-1 pl-0.5" id={"#{@id}-#{id}-#{slug(category)}-#{slug(library)}"}>
                          <span class="text-base-light-500 dark:text-base-dark-300">{library}</span>

                          <ul>
                            {#for %{name: item_name, to: to, id: item_id, active?: active?} <- items}
                              {id = id(category, library, item_name, id, item_id, @id)
                              nil}
                              <li
                                id={id}
                                class={
                                  "rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-750",
                                  "bg-base-light-200 dark:bg-base-dark-700 active-sidebar-nav": active?
                                }
                              >
                                <LivePatch
                                  to={to}
                                  opts={phx_click: mark_active(id)}
                                  class="flex flex-row items-start w-full text-left text-base-light-900 dark:text-base-dark-100"
                                >
                                  <Icon type={name} classes="h-4 w-4 flex-none mt-1 mr-1.5" />
                                  {item_name}
                                </LivePatch>
                              </li>
                            {/for}
                          </ul>
                        </li>
                      {/for}
                    </ul>
                  </li>
                {/for}
              </ul>
            </li>
          {/for}
        </ul>
      </div>
    </aside>
    """
  end

  defp id(category, library, name, id, item_id, global_id) do
    if category == "Tutorials" && library == "Ash" && name == "Get Started" do
      if String.starts_with?(global_id, "mobile") do
        "mobile-get-started-guide"
      else
        "get-started-guide"
      end
    else
      "#{global_id}-#{id}-#{slug(category)}-#{slug(library)}-#{item_id}"
    end
  end

  defp has_active?(list) when is_list(list), do: Enum.any?(list, &has_active?/1)
  defp has_active?({_, list}), do: has_active?(list)
  defp has_active?(%{active?: true}), do: true
  defp has_active?(_), do: false

  def mark_active(js \\ %JS{}, id) do
    js
    |> JS.remove_class(
      "bg-base-light-200 dark:bg-base-dark-700 active-sidebar-nav",
      to: ".active-sidebar-nav"
    )
    |> JS.add_class(
      "bg-base-light-200 dark:bg-base-dark-700 active-sidebar-nav",
      to: "##{id}"
    )
    |> JS.add_class(
      "bg-base-light-200 dark:bg-base-dark-700 active-sidebar-nav",
      to: "##{add_or_remove_mobile(id)}"
    )
  end

  def collapse(js \\ %JS{}, id) do
    js
    |> JS.remove_class(
      "rotate-[-90deg]",
      to: "##{id}-chevron.rotate-\\[-90deg\\]"
    )
    |> JS.remove_class(
      "rotate-[-90deg]",
      to: "##{add_or_remove_mobile(id)}-chevron.rotate-\\[-90deg\\]"
    )
    |> JS.add_class(
      "rotate-[-90deg]",
      to: "##{id}-chevron:not(.rotate-\\[-90deg\\])"
    )
    |> JS.add_class(
      "rotate-[-90deg]",
      to: "##{add_or_remove_mobile(id)}-chevron:not(.rotate-\\[-90deg\\])"
    )
    |> JS.toggle(to: "##{id}-contents")
    |> JS.toggle(to: "##{add_or_remove_mobile(id)}-contents")
  end

  defp add_or_remove_mobile("mobile-" <> rest), do: rest
  defp add_or_remove_mobile(rest), do: "mobile-#{rest}"

  defp slug(string) do
    string
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.replace(~r/[^a-z0-9-_]/, "-")
  end
end
