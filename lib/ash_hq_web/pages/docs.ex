defmodule AshHqWeb.Pages.Docs do
  @moduledoc "The page for showing documentation"
  use Phoenix.LiveComponent

  import AshHqWeb.Helpers
  import Tails

  alias AshHqWeb.Components.DocSidebar
  alias AshHqWeb.DocRoutes
  alias Phoenix.LiveView.JS
  require Logger
  require Ash.Query

  attr(:libraries, :list, default: [])
  attr(:uri, :string)
  attr(:params, :map, required: true)

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="flex flex-col xl:flex-row justify-center">
      <head>
        <meta property="og:title" content={@title} />
        <meta property="og:description" content={@description} />
      </head>
      <div class="xl:hidden sticky top-20 z-40 h-14 bg-white dark:bg-base-dark-850 flex flex-row justify-start w-full space-x-6 items-center border-b border-base-light-300 dark:border-base-dark-700 py-3">
        <button phx-click={show_sidebar()}>
          <span class="hero-bars-3 w-8 h-8 ml-4" />
        </button>
        <button id={"#{@id}-hide"} class="hidden" phx-click={hide_sidebar()} />
      </div>
      <span class="grid xl:hidden z-40">
        <div
          id="mobile-sidebar-container"
          class="hidden fixed transition sidebar-container overflow-y-auto z-40 border-r border-b border-base-light-300 dark:border-base-dark-700"
          phx-click-away={hide_sidebar()}
        >
          <.live_component
            module={DocSidebar}
            id="mobile-sidebar"
            class="max-w-sm p-2 pr-4"
            libraries={@libraries}
            remove_version={@remove_version}
            sidebar_data={@sidebar_data}
          />
        </div>
      </span>
      <div class="grow w-full flex flex-row max-w-[1800px] justify-between md:space-x-12">
        <div class="sidebar-container sticky overflow-y-auto overflow-x-hidden shrink-0 top-20 xl:border-r xl:border-b xl:border-base-light-300 xl:dark:border-base-dark-700 lg:pr-2 lg:pt-4">
          <.live_component
            module={DocSidebar}
            id="sidebar"
            class="hidden xl:block w-80"
            libraries={@libraries}
            remove_version={@remove_version}
            sidebar_data={@sidebar_data}
          />
        </div>
        <div
          :if={@not_found}
          id="docs-window"
          class="w-full shrink max-w-6xl prose prose-td:pl-0 bg-white dark:bg-base-dark-850 dark:prose-invert md:pr-8 md:mt-4 px-4 md:px-auto mx-auto overflow-x-auto overflow-y-hidden"
        >
          <div class="w-full nav-anchor text-black dark:text-white relative py-4 md:py-auto">
            <p>
              We couldn't find that page.
            </p>
            <p>
              A lot of our documentation has moved recently, if you can't find it here, look in the
              <a href="https://hexdocs.pm/ash/using-hexdocs.html">HexDocs</a>
            </p>
          </div>
        </div>
        <div
          :if={!@not_found}
          id="docs-window"
          class={
            classes([
              "w-full shrink max-w-6xl bg-white dark:bg-base-dark-850 md:pr-8 md:mt-4 px-4 md:px-auto mx-auto overflow-x-auto overflow-y-hidden prose prose-td:pl-0 dark:prose-invert"
            ])
          }
        >
          <div
            id="module-docs"
            class="w-full nav-anchor text-black dark:text-white relative py-4 md:py-auto"
          >
            <div class="flex flex-col float-right">
              <.github_guide_link
                :if={@guide}
                guide={@guide}
                library={@library}
                library_version={@library_version}
              />
              <.hex_guide_link
                :if={@guide}
                guide={@guide}
                library={@library}
                library_version={@library_version}
              />
            </div>
            <%= if @docs do %>
              <.docs docs={@docs} />
            <% end %>
          </div>

          <footer class="p-2 sm:justify-center">
            <div class="md:flex md:justify-around items-center">
              <.link href="/">
                <img class="h-6 md:h-10 hidden dark:block" src="/images/ash-framework-dark.png" />
                <img class="h-6 md:h-10 dark:hidden" src="/images/ash-framework-light.png" />
              </.link>
              <a href="https://github.com/ash-project" class="hover:underline">Source</a>
              <a
                href="https://github.com/ash-project/ash_hq/issues/new/choose"
                class="hover:underline"
              >
                Report an issue
              </a>
            </div>
          </footer>
        </div>
        <!-- empty div to preserve flex row spacing -->
        <div />
      </div>
    </div>
    """
  end

  def github_guide_link(assigns) do
    ~H"""
    <a
      href={source_link(@guide, @library, @library_version)}
      target="_blank"
      class="no-underline mt-1 ml-2 hidden lg:block"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="w-6 h-6 inline-block mr-1 -mt-1 dark:fill-white fill-base-light-600"
        viewBox="0 0 24 24"
      >
        <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
      </svg>
      <span class="underline">View this guide on GitHub</span>
      <span class="hero-link w-6 h-6 inline-block -mt-1" />
    </a>
    """
  end

  def hex_guide_link(assigns) do
    ~H"""
    <a
      href={hex_link(@guide, @library, @library_version)}
      target="_blank"
      class="no-underline mt-1 ml-2 hidden lg:block"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="w-6 h-6 inline-block mr-1 -mt-1 dark:fill-white fill-base-light-600"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25"
        />
      </svg>
      <span class="underline">View this guide on Hex</span>
      <span class="hero-link w-6 h-6 inline-block -mt-1" />
    </a>
    """
  end

  def docs(assigns) do
    ~H"""
    <div id="doc-text">
      {Phoenix.HTML.raw(@docs)}
    </div>
    """
  end

  def update(assigns, socket) do
    if socket.assigns[:loaded_once?] do
      {:ok, socket |> assign(Map.delete(assigns, :libraries)) |> load_docs()}
    else
      {:ok,
       socket
       |> assign(not_found: false)
       |> assign(assigns)
       |> assign_libraries()
       |> load_docs()
       |> assign_sidebar_content()
       |> assign(:loaded_once?, true)}
    end
  end

  def show_sidebar(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#mobile-sidebar-container",
      in: {
        "transition ease-in duration-100",
        "opacity-0",
        "opacity-100"
      },
      out: {
        "transition ease-out duration-75",
        "opacity-100",
        "opacity-0"
      }
    )
  end

  def hide_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#mobile-sidebar-container",
      transition: {
        "transition ease-out duration-75",
        "opacity-100",
        "opacity-0"
      }
    )
  end

  def assign_libraries(socket) do
    socket = assign_library(socket)

    guides_query =
      AshHq.Docs.Guide
      |> Ash.Query.new()
      |> load_for_search()

    new_libraries =
      Ash.load!(socket.assigns.libraries, versions: [guides: guides_query])

    assign(socket, :libraries, new_libraries)
  end

  def load_docs(socket) do
    socket
    |> assign_library()
    |> assign_guide()
    |> assign_fallback_guide()
    |> assign_docs()
  end

  defp assign_sidebar_content(socket) do
    sidebar_data =
      guides_by_category_and_library(
        socket.assigns[:libraries],
        socket.assigns[:guide]
      )

    assign(socket, sidebar_libraries: socket.assigns.libraries, sidebar_data: sidebar_data)
  end

  @start_guides ["Tutorials", "Topics", "How To", "Misc"]

  defp guides_by_category_and_library(libraries, active_guide) do
    libraries
    |> Enum.map(fn library ->
      {library, Enum.at(library.versions, 0)}
    end)
    |> Enum.filter(fn {_library, version} -> version != nil end)
    |> Enum.sort_by(fn {library, _version} -> library.order end)
    |> Enum.flat_map(fn {library, %{guides: guides}} ->
      guides
      |> Enum.sort_by(& &1.order)
      |> Enum.group_by(& &1.category, fn guide ->
        %{
          id: guide.id,
          name: guide.name,
          to: DocRoutes.doc_link(guide),
          active?: active_guide && active_guide.id == guide.id
        }
      end)
      |> Enum.map(fn {category, guides} -> {category, {library.display_name, guides}} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> partially_alphabetically_sort(@start_guides, [])
  end

  defp partially_alphabetically_sort(keyed_list, first, last) do
    {first_items, rest} =
      Enum.split_with(keyed_list, fn {key, _} ->
        key in first
      end)

    {last_items, rest} =
      Enum.split_with(rest, fn {key, _} ->
        key in last
      end)

    first_items
    |> Enum.sort_by(fn {key, _} ->
      Enum.find_index(first, &(&1 == key))
    end)
    |> Enum.concat(Enum.sort_by(rest, &elem(&1, 0)))
    |> Enum.concat(
      Enum.sort_by(last_items, fn {key, _} ->
        Enum.find_index(last, &(&1 == key))
      end)
    )
  end

  def slug(string) do
    string
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.replace(~r/[^a-z0-9-_]/, "-")
  end

  defp assign_fallback_guide(socket) do
    if socket.assigns[:library_version] && !socket.assigns[:guide] do
      guide =
        Enum.find(socket.assigns.library_version.guides, fn guide ->
          guide.default
        end) ||
          Enum.find(socket.assigns.library_version.guides, fn guide ->
            String.contains?(guide.sanitized_name, "started")
          end) || Enum.at(socket.assigns.library_version.guides, 0)

      guide = guide |> reselect!(:text_html)

      assign(socket, guide: guide)
    else
      socket
    end
  end

  defp reselect!(%resource{} = record, field) do
    if Ash.Resource.selected?(record, field) do
      record
    else
      # will blow up if pkey is not an id or if its not a docs resource
      # but w/e
      value =
        resource
        |> Ash.Query.select(field)
        |> Ash.Query.filter(id == ^record.id)
        |> Ash.read_one!()
        |> Map.get(field)

      Map.put(record, field, value)
    end
  end

  defp reselect!(nil, _), do: nil

  defp reselect_and_get!(record, field) do
    record
    |> reselect!(field)
    |> Map.get(field)
  end

  defp load_for_search(query) do
    query
    |> Ash.Query.load(AshHq.Docs.Extensions.Search.load_for_search(query.resource))
    |> deselect_doc_attributes()
  end

  defp deselect_doc_attributes(query) do
    query.resource
    |> AshHq.Docs.Extensions.RenderMarkdown.render_attributes()
    |> Enum.reduce(query, fn {source, target}, query ->
      Ash.Query.deselect(query, [source, target])
    end)
  end

  defp assign_library(socket) do
    case Enum.find(
           socket.assigns.libraries,
           &(&1.name == socket.assigns.params["library"])
         ) do
      nil ->
        library = Enum.find(socket.assigns.libraries, &(&1.name == "ash"))

        assign(socket,
          not_found: true,
          library: library,
          library_version: AshHqWeb.Helpers.latest_version(library)
        )

      library ->
        socket
        |> assign(:library, library)
        |> assign(:library_version, AshHqWeb.Helpers.latest_version(library))
    end
  end

  defp assign_guide(socket) do
    guide_route = socket.assigns[:params]["guide"]

    guide =
      if guide_route && socket.assigns.library_version do
        guide_route = Enum.map(List.wrap(guide_route), &String.trim_trailing(&1, ".md"))

        Enum.find(socket.assigns.library_version.guides, fn guide ->
          matches_path?(guide, guide_route) || matches_name?(guide, guide_route)
        end)
      end

    assign(socket, :guide, guide)
  end

  defp matches_path?(guide, guide_route) do
    guide.sanitized_route == DocRoutes.sanitize_name(Enum.join(guide_route, "/"), true)
  end

  defp matches_name?(guide, list) do
    guide_name = List.last(list)
    DocRoutes.sanitize_name(guide.name) == DocRoutes.sanitize_name(guide_name)
  end

  defp assign_docs(socket) do
    if socket.assigns.guide do
      send(self(), {:page_title, socket.assigns.guide.name})

      assign(socket,
        title: "Guide: #{socket.assigns.guide.name}",
        docs: socket.assigns.guide |> reselect_and_get!(:text_html),
        description: "Read the \"#{socket.assigns.guide.name}\" guide on Ash HQ"
      )
    else
      assign(socket,
        docs: "",
        title: "Ash Framework",
        description: default_description()
      )
    end
  end

  defp default_description do
    "A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
  end
end
