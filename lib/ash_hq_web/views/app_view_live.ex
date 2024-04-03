defmodule AshHqWeb.AppViewLive do
  # credo:disable-for-this-file Credo.Check.Readability.MaxLineLength
  use Phoenix.LiveView,
    container: {:div, class: "h-full"}

  alias AshHqWeb.Components.AppView.TopBar

  alias AshHqWeb.Components.Search
  alias AshHqWeb.Pages.{Blog, Community, Docs, Forum, Home, Media}

  alias Phoenix.LiveView.JS
  require Ash.Query

  import AshHqWeb.Tails

  def render(assigns) do
    ~H"""
    <div id="app" class={classes("h-full font-sans": true)} phx-hook="ColorTheme">
      <head>
        <meta property="og:type" content="text/html">
        <meta property="og:image" content="https://ash-hq.org/images/ash-logo-side.png">
        <meta property="og:url" content={to_string(@uri)}>
        <meta property="og:site_name" content="Ash HQ">
        <meta property="twitter:card" content="summary_large_image">
        <meta property="twitter:domain" content="ash-hq.org">
        <meta property="twitter:site" content="@AshFramework">
        <!-- Need to adjust this for future blog writers -->
        <meta property="twitter:creator" content="@ZachSDaniel1">

        <%= if @live_action not in [:docs_dsl, :blog, :forum] do %>
          <meta property="og:title" content="Ash Framework">
          <meta
            property="og:description"
            content="A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
          />
        <% end %>
      </head>
      <.live_component
        module={Search}
        id="search-box"
        uri={@uri}
        close={close_search()}
        libraries={@libraries}
        change_types="change-types"
        change_versions="change-versions"
        remove_version="remove_version"
      />
      <button id="search-button" class="hidden" phx-click={AshHqWeb.AppViewLive.toggle_search()} />
      <div
        id="main-container"
        class={classes([
          "w-full min-h-screen bg-white dark:bg-base-dark-850 dark:text-white flex flex-col items-stretch",
          "h-screen overflow-y-auto": @live_action != :docs_dsl
        ])
        }
      >
        <TopBar.top_bar
          live_action={@live_action}
          configured_theme={@configured_theme}
          current_user={@current_user}
        />
        <%= case @live_action do %>
          <% :home -> %>
          <.live_component module={Home} id="home" device_brand={@device_brand} />
          <% :blog -> %>
            <.live_component module={Blog} id="blog" params={@params} />
          <% :community -> %>
            <Community.community />
          <% :docs_dsl -> %>
            <.live_component module={Docs}
              id="docs"
              uri={@uri}
              params={@params}
              remove_version="remove_version"
              change_versions="change-versions"
              libraries={@libraries}
            />
          <% :media -> %>
            <Media.media id="media" />
          <% :forum -> %>
            <.live_component module={Forum} id="forum" params={@params} />
        <% end %>

        <%= if @live_action != :docs_dsl do %>
          <footer class="p-8 sm:p-6 bg-base-light-200 dark:bg-base-dark-850 sm:justify-center sticky">
            <div class="md:flex md:justify-around">
              <div class="flex justify-center flex-row mb-6 md:mb-0">
                <a href="/" class="flex items-center">
                  <img src="/images/ash-logo-side.svg" class="mr-3 h-32" alt="Ash Framework Logo">
                </a>
              </div>

              <div class="grid grid-cols-3 gap-8 sm:gap-6">
                <div>
                  <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">Resources</h2>
                  <ul class="text-gray-600 dark:text-gray-400">
                    <li class="mb-4">
                      <a href="https://github.com/ash-project" class="hover:underline">Source</a>
                    </li>
                    <li class="mb-4">
                      <a href="/docs/guides/ash/latest/tutorials/get-started" class="hover:underline">Get Started</a>
                    </li>
                    <li class="mb-4">
                      <a href="/blog" class="hover:underline">Blog</a>
                    </li>
                    <li>
                      <a href="/media" class="hover:underline">Media</a>
                    </li>
                  </ul>
                </div>
                <div>
                  <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">Community</h2>
                  <ul class="text-gray-600 dark:text-gray-400">
                    <li class="mb-4">
                      <a href="https://twitter.com/AshFramework" class="hover:underline">Twitter</a>
                    </li>
                    <li>
                      <a href="https://discord.gg/D7FNG2q" class="hover:underline">Discord</a>
                    </li>
                  </ul>
                </div>
                <div>
                  <h2 class="mb-6 text-sm font-semibold text-gray-900 uppercase dark:text-white">Help Us</h2>
                  <ul class="text-gray-600 dark:text-gray-400">
                    <li class="mb-4">
                      <a href="https://github.com/ash-project/ash_hq/issues/new/choose" class="hover:underline">Report an issue</a>
                    </li>
                    <li class="mb-4">
                      <a href="https://ash-hq.appsignal-status.com" class="hover:underline">Status Page</a>
                    </li>
                    <li>
                      <a href="/docs/guides/ash/latest/how_to/contribute" class="hover:underline">Contribute</a>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </footer>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_params(params, uri, socket) do
    {:noreply,
     socket
     |> assign(params: params, uri: uri)}
  end

  def handle_info({:page_title, title}, socket) do
    {:noreply, assign(socket, :page_title, "Ash Framework - #{title}")}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
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

  def mount(_params, session, socket) do
    socket = assign(socket, :page_title, "Ash Framework")

    socket =
      assign_new(socket, :user_agent, fn _assigns ->
        get_connect_params(socket)["user_agent"]
      end)

    socket = assign(socket, :device_brand, "Apple")

    configured_theme = session["theme"] || "system"

    versions_query =
      AshHq.Docs.LibraryVersion
      |> Ash.Query.sort(version: :desc)

    libraries = AshHq.Docs.Library.read!(load: [versions: versions_query])

    {:ok,
     socket
     |> assign(:libraries, libraries)
     |> assign(configured_theme: configured_theme)}
  end

  def toggle_search(js \\ %JS{}) do
    js
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
    |> JS.hide(
      transition: "fade-out",
      to: "#search-box"
    )
    |> JS.hide(transition: "fade-out", to: "#search-versions")
    |> JS.show(transition: "fade-in", to: "#search-body")
  end
end
