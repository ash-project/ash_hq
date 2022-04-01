defmodule AshHqWeb.AppViewLive do
  use Surface.LiveView,
    container: {:div, class: "h-full"}

  alias AshHqWeb.Components.Search
  alias AshHqWeb.Pages.{Docs, Home}
  alias Phoenix.LiveView.JS
  require Ash.Query

  data configured_theme, :string, default: :system
  data searching, :boolean, default: false
  data selected_versions, :map, default: %{}
  data libraries, :list, default: []
  data selected_types, :map, default: %{}
  data sidebar_state, :map, default: %{}

  def render(assigns) do
    ~F"""
    <div
      id="app"
      class={"h-full font-sans": true, "#{@configured_theme}": true}
      phx-hook="ColorTheme"
    >
      <Search
        id="search-box"
        uri={@uri}
        close={close_search()}
        libraries={@libraries}
        selected_types={@selected_types}
        change_types="change-types"
        change_versions="change-versions"
        selected_versions={@selected_versions}
      />
      <button id="search-button" class="hidden" phx-click={AshHqWeb.AppViewLive.toggle_search()} />
      <div
        id="main-container"
        class={"h-screen grid content-start grid-rows-[auto,1fr] w-screen bg-white dark:bg-primary-black dark:text-silver-phoenix", "overflow-scroll": @live_action == :home, "overflow-hidden": @live_action == :docs_dsl}
      >
        <div class={
          "flex justify-between pt-4 px-4 h-min",
          "border-b bg-white dark:bg-primary-black": @live_action == :docs_dsl
        }>
          <div class="flex flex-row align-baseline">
            <a href="/">
              <img class="h-10 hidden dark:block" src="/images/ash-framework-dark.png">
              <img class="h-10 dark:hidden" src="/images/ash-framework-light.png">
            </a>
          </div>
          <div class="flex flex-row align-middle items-center space-x-2">
            <a
              href="/docs/guides/ash/main/getting-started"
              class="dark:text-gray-400 dark:hover:text-gray-200 hover:text-gray-600"
            >Get Started</a>
            <div>|</div>
            <a href="/docs/guides/ash/main/overview" class="dark:text-gray-400 dark:hover:text-gray-200 hover:text-gray-600">Docs</a>
            <div>|</div>
            <a href="https://github.com/ash-project">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-6 h-6 dark:fill-gray-400 dark:hover:fill-gray-200 hover:fill-gray-600"
                viewBox="0 0 24 24"
              ><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" /></svg>
            </a>
            <button phx-click="toggle_theme">
              {#case @configured_theme}
                {#match "light"}
                  <Heroicons.Outline.SunIcon class="w-6 h-6 hover:text-gray-600" />
                {#match _}
                  <Heroicons.Outline.MoonIcon class="w-6 h-6 text-gray-400 fill-gray-400 hover:fill-gray-200 hover:text-gray-200" />
              {/case}
            </button>
          </div>
        </div>
        {#case @live_action}
          {#match :home}
            <Home id="home" />
          {#match :docs_dsl}
            <Docs
              id="docs"
              params={@params}
              uri={@uri}
              collapse_sidebar="collapse_sidebar"
              expand_sidebar="expand_sidebar"
              sidebar_state={@sidebar_state}
              change_versions="change-versions"
              selected_versions={@selected_versions}
              libraries={@libraries}
            />
        {/case}
      </div>
    </div>
    """
  end

  def handle_params(params, uri, socket) do
    {:noreply, assign(socket, params: params, uri: uri)}
  end

  def handle_event("collapse_sidebar", %{"id" => id}, socket) do
    new_state = Map.put(socket.assigns.sidebar_state, id, "closed")

    {:noreply,
     socket |> assign(:sidebar_state, new_state) |> push_event("js:sidebar-state", new_state)}
  end

  def handle_event("expand_sidebar", %{"id" => id}, socket) do
    new_state = Map.put(socket.assigns.sidebar_state, id, "open")

    {:noreply,
     socket |> assign(:sidebar_state, new_state) |> push_event("sidebar-state", new_state)}
  end

  def handle_event("change-versions", %{"versions" => versions}, socket) do
    {:noreply,
     socket
     |> assign(:selected_versions, versions)
     |> load_docs()
     |> push_event("selected-versions", versions)}
  end

  def handle_event("change-types", %{"types" => types}, socket) do
    types =
      types
      |> Enum.filter(fn {_, value} ->
        value == "true"
      end)
      |> Enum.map(&elem(&1, 0))

    {:noreply,
     socket
     |> assign(
       :selected_types,
       types
     )
     |> push_event("selected-types", %{types: types})}
  end

  def handle_event("toggle_theme", _, socket) do
    theme =
      case socket.assigns.configured_theme do
        "light" ->
          "dark"

        "dark" ->
          "light"
      end

    {:noreply,
     socket
     |> assign(:configured_theme, theme)
     |> push_event("set_theme", %{theme: theme})}
  end

  def handle_info({:new_sidebar_state, new_state}, socket) do
    {:noreply,
     socket |> assign(:sidebar_state, new_state) |> push_event("sidebar-state", new_state)}
  end

  defp load_docs(socket) do
    new_libraries =
      socket.assigns.libraries
      |> Enum.map(fn library ->
        Map.update!(library, :versions, fn versions ->
          Enum.map(versions, fn version ->
            if version.id == socket.assigns[:selected_versions][library.id] do
              dsls_query = Ash.Query.sort(AshHq.Docs.Dsl, order: :asc)
              options_query = Ash.Query.sort(AshHq.Docs.Option, order: :asc)
              functions_query = Ash.Query.sort(AshHq.Docs.Function, name: :asc, arity: :asc)

              modules_query =
                AshHq.Docs.Module
                |> Ash.Query.sort(order: :asc)
                |> Ash.Query.load(functions: functions_query)

              extensions_query =
                AshHq.Docs.Extension
                |> Ash.Query.sort(order: :asc)
                |> Ash.Query.load(options: options_query, dsls: dsls_query)

              AshHq.Docs.load!(version,
                extensions: extensions_query,
                guides: :url_safe_name,
                modules: modules_query
              )
            else
              version
            end
          end)
        end)
      end)

    assign(socket, :libraries, new_libraries)
  end

  def mount(_params, session, socket) do
    configured_theme = session["theme"] || "dark"

    configured_library_versions =
      case session["selected_versions"] do
        nil ->
          %{}

        "" ->
          %{}

        value ->
          value
          |> String.split(",")
          |> Map.new(fn str ->
            str
            |> String.split(":")
            |> List.to_tuple()
          end)
      end

    all_types = AshHq.Docs.Extensions.Search.Types.types()

    selected_types =
      case session["selected_types"] do
        nil ->
          AshHq.Docs.Extensions.Search.Types.types()

        types ->
          types
          |> String.split(",")
          |> Enum.filter(&(&1 in all_types))
      end

    sidebar_state =
      case session["sidebar_state"] do
        nil ->
          %{}

        value ->
          value
          |> String.split(",")
          |> Map.new(fn str ->
            str
            |> String.split(":")
            |> List.to_tuple()
          end)
      end

    socket =
      socket
      |> assign(:selected_versions, configured_library_versions)
      |> AshPhoenix.LiveView.keep_live(
        :libraries,
        fn _socket ->
          versions_query =
            AshHq.Docs.LibraryVersion
            |> Ash.Query.sort(version: :desc)
            |> Ash.Query.filter(processed == true)
            |> Ash.Query.deselect(:data)

          AshHq.Docs.Library.read!(load: [versions: versions_query])
        end,
        after_fetch: fn results, socket ->
          selected_versions =
            Enum.reduce(results, socket.assigns[:selected_versions] || %{}, fn library, acc ->
              case Enum.at(library.versions, 0) do
                nil ->
                  acc

                version ->
                  Map.put_new(acc, library.id, version.id)
              end
            end)

          socket
          |> assign(
            :selected_versions,
            selected_versions
          )
          |> assign(
            :selected_types,
            selected_types
          )
          |> push_event("selected_versions", selected_versions)
          |> push_event("selected_types", %{types: selected_types})
        end
      )
      |> load_docs()

    {:ok, assign(socket, configured_theme: configured_theme, sidebar_state: sidebar_state)}
  end

  def toggle_search(js \\ %JS{}) do
    js
    |> JS.dispatch("js:noscroll-main", to: "#search-box")
    |> JS.toggle(
      to: "#search-box",
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
    |> JS.dispatch("js:focus", to: "#search-input")
  end

  def close_search(js \\ %JS{}) do
    js
    |> JS.dispatch("js:noscroll-main", to: "#search-box")
    |> JS.hide(
      transition: "fade-out",
      to: "#search-box"
    )
    |> JS.dispatch("js:focus", to: "#search-input")
  end
end
