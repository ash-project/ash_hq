defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc """
  Renders the sidebar data, and uses `Phoenix.LiveView.JS` to manage selection/collapsible state.
  """
  use Surface.LiveComponent

  alias AshHqWeb.Components.Icon
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
        <ul class="ml-2 mt-4">
          {#for {category, items} <- @sidebar_data}
            <li class="pt-1 pl-0.5" id={"#{@id}-guides-#{slug(category)}"}>
              <button
                class="flex flex-row items-start w-full text-left rounded-lg hover:bg-base-light-100 dark:hover:bg-base-dark-750 p-[0.1rem]"
                phx-click={collapse("#{@id}-guides-#{slug(category)}")}
              >
                <div
                  class={"chevron mr-1.5 mt-1.5 origin-center", "rotate-[-90deg]": !has_active?(items)}
                  id={"#{@id}-guides-#{slug(category)}-chevron"}
                >
                  <Heroicons.Outline.ChevronDownIcon class="w-3 h-3" />
                </div>
                <span class="text-base-light-500 dark:text-base-dark-300 font-bold">{category}</span>
              </button>

              <ul
                class="ml-4"
                id={"#{@id}-guides-#{slug(category)}-contents"}
                style={if !has_active?(items), do: "display: none", else: ""}
              >
                {#for {library, items} <- items}
                  <li class="pt-1 pl-0.5" id={"#{@id}-guides-#{slug(category)}-#{slug(library)}"}>
                    <span class="text-primary-dark-500 dark:text-primary-light-500 font-extrabold">{library}</span>

                    <ul>
                      {#for %{name: item_name, to: to, id: item_id, active?: active?} <- items}
                        {id = id(category, library, item_name, "guides", item_id, @id)
                        nil}
                        <li
                          id={id}
                          class={
                            "first:rounded-t-lg last:rounded-b-lg p-[0.1rem] pl-1 hover:bg-base-light-100 dark:hover:bg-base-dark-750",
                            "bg-base-light-200 dark:bg-base-dark-750 active-sidebar-nav": active?
                          }
                        >
                          <LivePatch
                            to={to}
                            opts={phx_click: mark_active(id)}
                            class="flex flex-row items-start w-full text-left text-base-light-900 dark:text-base-dark-100"
                          >
                            <Icon type="Guides" classes="h-4 w-4 flex-none mt-1 mr-1.5" />
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
      "bg-base-light-200 dark:bg-base-dark-750 active-sidebar-nav",
      to: ".active-sidebar-nav"
    )
    |> JS.add_class(
      "bg-base-light-200 dark:bg-base-dark-750 active-sidebar-nav",
      to: "##{id}"
    )
    |> JS.add_class(
      "bg-base-light-200 dark:bg-base-dark-750 active-sidebar-nav",
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
