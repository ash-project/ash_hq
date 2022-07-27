defmodule AshHqWeb.AppViewLive do
  use Surface.LiveView,
    container: {:div, class: "h-full"}

  alias AshHqWeb.Components.{Search, SearchBar}
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
        class={
          "h-screen grid content-start grid-rows-[auto,1fr] w-screen bg-white dark:bg-primary-black dark:text-white",
          "overflow-scroll overflow-x-hidden": @live_action == :home,
          "overflow-hidden": @live_action == :docs_dsl
        }
      >
        <div class={
          "flex justify-between items-center py-4 px-4 h-min",
          "border-b bg-white dark:bg-primary-black": @live_action == :docs_dsl
        }>
          <div class="flex flex-row align-baseline">
            <a href="/">
              <img class="h-10 hidden dark:block" src="/images/ash-framework-dark.png">
              <img class="h-10 dark:hidden" src="/images/ash-framework-light.png">
            </a>
          </div>
          {#if @live_action == :docs_dsl}
            <SearchBar class="hidden lg:block" />
          {/if}
          <div class="flex flex-row align-middle items-center space-x-2">
            <a
              href="/docs/guides/ash/main/tutorials/quick-start.md"
              target="_blank"
              class="dark:text-gray-400 dark:hover:text-gray-200 hover:text-gray-600"
            >Quick Start</a>
            <div>|</div>
            <a
              href="/docs/guides/ash/main/topics/overview.md"
              target="_blank"
              class="dark:text-gray-400 dark:hover:text-gray-200 hover:text-gray-600"
            >Docs</a>
            <div>|</div>
            <a href="https://github.com/ash-project" target="_blank">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-6 h-6 dark:fill-gray-400 dark:hover:fill-gray-200 hover:fill-gray-600"
                viewBox="0 0 24 24"
              ><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" /></svg>
            </a>
            <a href="https://discord.gg/D7FNG2q" target="_blank">
              <svg
                class="w-6 h-6 fill-black dark:fill-gray-400 dark:hover:fill-gray-200 hover:fill-gray-600"
                viewBox="0 0 71 55"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <g clip-path="url(#clip0)">
                  <path d="M60.1045 4.8978C55.5792 2.8214 50.7265 1.2916 45.6527 0.41542C45.5603 0.39851 45.468 0.440769 45.4204 0.525289C44.7963 1.6353 44.105 3.0834 43.6209 4.2216C38.1637 3.4046 32.7345 3.4046 27.3892 4.2216C26.905 3.0581 26.1886 1.6353 25.5617 0.525289C25.5141 0.443589 25.4218 0.40133 25.3294 0.41542C20.2584 1.2888 15.4057 2.8186 10.8776 4.8978C10.8384 4.9147 10.8048 4.9429 10.7825 4.9795C1.57795 18.7309 -0.943561 32.1443 0.293408 45.3914C0.299005 45.4562 0.335386 45.5182 0.385761 45.5576C6.45866 50.0174 12.3413 52.7249 18.1147 54.5195C18.2071 54.5477 18.305 54.5139 18.3638 54.4378C19.7295 52.5728 20.9469 50.6063 21.9907 48.5383C22.0523 48.4172 21.9935 48.2735 21.8676 48.2256C19.9366 47.4931 18.0979 46.6 16.3292 45.5858C16.1893 45.5041 16.1781 45.304 16.3068 45.2082C16.679 44.9293 17.0513 44.6391 17.4067 44.3461C17.471 44.2926 17.5606 44.2813 17.6362 44.3151C29.2558 49.6202 41.8354 49.6202 53.3179 44.3151C53.3935 44.2785 53.4831 44.2898 53.5502 44.3433C53.9057 44.6363 54.2779 44.9293 54.6529 45.2082C54.7816 45.304 54.7732 45.5041 54.6333 45.5858C52.8646 46.6197 51.0259 47.4931 49.0921 48.2228C48.9662 48.2707 48.9102 48.4172 48.9718 48.5383C50.038 50.6034 51.2554 52.5699 52.5959 54.435C52.6519 54.5139 52.7526 54.5477 52.845 54.5195C58.6464 52.7249 64.529 50.0174 70.6019 45.5576C70.6551 45.5182 70.6887 45.459 70.6943 45.3942C72.1747 30.0791 68.2147 16.7757 60.1968 4.9823C60.1772 4.9429 60.1437 4.9147 60.1045 4.8978ZM23.7259 37.3253C20.2276 37.3253 17.3451 34.1136 17.3451 30.1693C17.3451 26.225 20.1717 23.0133 23.7259 23.0133C27.308 23.0133 30.1626 26.2532 30.1066 30.1693C30.1066 34.1136 27.28 37.3253 23.7259 37.3253ZM47.3178 37.3253C43.8196 37.3253 40.9371 34.1136 40.9371 30.1693C40.9371 26.225 43.7636 23.0133 47.3178 23.0133C50.9 23.0133 53.7545 26.2532 53.6986 30.1693C53.6986 34.1136 50.9 37.3253 47.3178 37.3253Z" />
                </g>
                <defs>
                  <clipPath id="clip0">
                    <rect width="71" height="55" fill="white" />
                  </clipPath>
                </defs>
              </svg>
            </a>
            <a href="https://twitter.com/ashframework" target="_blank">
              <svg
                class="w-6 h-6 dark:fill-gray-400 dark:hover:fill-gray-200 hover:fill-gray-600"
                version="1.1"
                viewBox="0 0 248 204"
                style="enable-background:new 0 0 248 204;"
              >
                <g id="Logo_1_">
                  <path d="M221.95,51.29c0.15,2.17,0.15,4.34,0.15,6.53c0,66.73-50.8,143.69-143.69,143.69v-0.04
    C50.97,201.51,24.1,193.65,1,178.83c3.99,0.48,8,0.72,12.02,0.73c22.74,0.02,44.83-7.61,62.72-21.66
    c-21.61-0.41-40.56-14.5-47.18-35.07c7.57,1.46,15.37,1.16,22.8-0.87C27.8,117.2,10.85,96.5,10.85,72.46c0-0.22,0-0.43,0-0.64
    c7.02,3.91,14.88,6.08,22.92,6.32C11.58,63.31,4.74,33.79,18.14,10.71c25.64,31.55,63.47,50.73,104.08,52.76
    c-4.07-17.54,1.49-35.92,14.61-48.25c20.34-19.12,52.33-18.14,71.45,2.19c11.31-2.23,22.15-6.38,32.07-12.26
    c-3.77,11.69-11.66,21.62-22.2,27.93c10.01-1.18,19.79-3.86,29-7.95C240.37,35.29,231.83,44.14,221.95,51.29z" />
                </g>
              </svg>
            </a>
            <div>|</div>
            <button phx-click="toggle_theme">
              {#case @configured_theme}
                {#match "light"}
                  <Heroicons.Solid.SunIcon class="w-6 h-6 hover:text-gray-600" />
                {#match "system"}
                  <Heroicons.Solid.DesktopComputerIcon class="w-6 h-6 fill-gray-400 dark:text-black dark:hover:text-gray-600 hover:text-gray-600" />
                {#match _}
                  <Heroicons.Solid.MoonIcon class="w-6 h-6 fill-gray-400 hover:fill-gray-200 hover:text-gray-200" />
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
          "system"

        "system" ->
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
        latest_version = AshHqWeb.Helpers.latest_version(library)

        Map.update!(library, :versions, fn versions ->
          Enum.map(versions, fn version ->
            if (socket.assigns[:selected_versions][library.id] in ["latest", nil, ""] &&
                  latest_version &&
                  version.id == latest_version.id) ||
                 version.id == socket.assigns[:selected_versions][library.id] do
              dsls_query = AshHq.Docs.Dsl |> Ash.Query.sort(order: :asc) |> load_for_search()

              options_query =
                AshHq.Docs.Option |> Ash.Query.sort(order: :asc) |> load_for_search()

              functions_query =
                AshHq.Docs.Function
                |> Ash.Query.sort(name: :asc, arity: :asc)
                |> load_for_search()

              guides_query = AshHq.Docs.Guide |> Ash.Query.new() |> load_for_search()

              modules_query =
                AshHq.Docs.Module
                |> Ash.Query.sort(order: :asc)
                |> Ash.Query.load(functions: functions_query)
                |> load_for_search()

              extensions_query =
                AshHq.Docs.Extension
                |> Ash.Query.sort(order: :asc)
                |> Ash.Query.load(options: options_query, dsls: dsls_query)
                |> load_for_search()

              AshHq.Docs.load!(version,
                extensions: extensions_query,
                guides: guides_query,
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
    configured_theme = session["theme"] || "system"

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

    versions_query =
      AshHq.Docs.LibraryVersion
      |> Ash.Query.sort(version: :desc)

    libraries = AshHq.Docs.Library.read!(load: [versions: versions_query])

    selected_versions =
      Enum.reduce(libraries, %{}, fn library, acc ->
        # for now we only assume that ash will always appear in the docs
        if library.name == "ash" do
          case AshHqWeb.Helpers.latest_version(library) do
            nil ->
              acc

            version ->
              Map.put_new(acc, library.id, version.id)
          end
        else
          acc
        end
      end)

    {:ok,
     socket
     |> assign(:libraries, libraries)
     |> assign(
       :selected_versions,
       selected_versions
     )
     |> assign(
       :selected_types,
       selected_types
     )
     |> assign(:selected_versions, configured_library_versions)
     |> assign(configured_theme: configured_theme, sidebar_state: sidebar_state)
     |> push_event("selected-versions", selected_versions)
     |> push_event("selected_types", %{types: selected_types})
     |> load_docs()}
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

  defp load_for_search(query) do
    Ash.Query.load(
      query,
      AshHq.Docs.Extensions.Search.load_for_search(query.resource)
    )
  end
end
