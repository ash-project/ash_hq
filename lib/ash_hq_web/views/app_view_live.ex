defmodule AshHqWeb.AppViewLive do
  # credo:disable-for-this-file Credo.Check.Readability.MaxLineLength
  use Surface.LiveView,
    container: {:div, class: "h-full"}

  alias AshHqWeb.Components.AppView.TopBar
  alias AshHqWeb.Components.{CatalogueModal, Search}
  alias AshHqWeb.Pages.{Blog, Docs, Forum, Home, Media, UserSettings}
  alias Phoenix.LiveView.JS
  alias Surface.Components.Context
  require Ash.Query

  import AshHqWeb.Tails

  data configured_theme, :string, default: :system
  data selected_versions, :map, default: %{}
  data libraries, :list, default: []
  data selected_types, :map, default: %{}
  data current_user, :map

  data library, :any, default: nil
  data extension, :any, default: nil
  data docs, :any, default: nil
  data library_version, :any, default: nil
  data guide, :any, default: nil
  data doc_path, :list, default: []
  data dsls, :list, default: []
  data dsl, :any, default: nil
  data options, :list, default: []
  data module, :any, default: nil

  def render(%{platform: :ios} = assigns) do
    ~F"""
    {#case @live_action}
      {#match :home}
        <Home id="home" />
    {/case}
    """
  end

  def render(assigns) do
    ~F"""
    <div
      id="app"
      class={classes([@configured_theme, "h-full font-sans": true])}
      phx-hook="ColorTheme"
    >
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

        {#if @live_action not in [:docs_dsl, :blog, :forum]}
          <meta property="og:title" content="Ash Framework">
          <meta
            property="og:description"
            content="A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
          />
        {/if}
      </head>
      <Search
        id="search-box"
        uri={@uri}
        close={close_search()}
        libraries={@libraries}
        selected_types={@selected_types}
        change_types="change-types"
        selected_versions={@selected_versions}
        change_versions="change-versions"
        remove_version="remove_version"
      />
      <CatalogueModal
        id="catalogue-box"
        libraries={@libraries}
        selected_versions={@selected_versions}
        change_versions="change-versions"
      />
      <button id="search-button" class="hidden" phx-click={AshHqWeb.AppViewLive.toggle_search()} />
      <div
        id="main-container"
        class={
          "w-full min-h-screen bg-white dark:bg-base-dark-850 dark:text-white flex flex-col items-stretch",
          "h-screen overflow-y-auto": @live_action != :docs_dsl
        }
      >
        <TopBar
          live_action={@live_action}
          toggle_theme="toggle_theme"
          configured_theme={@configured_theme}
          current_user={@current_user}
        />
        {#for flash <- List.wrap(live_flash(@flash, :error))}
          <p class="alert alert-warning" role="alert">{flash}</p>
        {/for}
        {#for flash <- List.wrap(live_flash(@flash, :info))}
          <p class="alert alert-info max-h-min" role="alert">{flash}</p>
        {/for}
        {#case @live_action}
          {#match :home}
            <Home id="home" device_brand={@device_brand} />
          {#match :blog}
            <Blog id="blog" params={@params} />
          {#match :docs_dsl}
            <Docs
              id="docs"
              uri={@uri}
              params={@params}
              remove_version="remove_version"
              change_versions="change-versions"
              selected_versions={@selected_versions}
              libraries={@libraries}
              show_catalogue_call_to_action={@show_catalogue_call_to_action}
            />
          {#match :user_settings}
            <UserSettings id="user_settings" current_user={@current_user} />
          {#match :media}
            <Media id="media" />
          {#match :forum}
            <Forum id="forum" params={@params} />
        {/case}

        {#if @live_action != :docs_dsl}
          <footer class="p-8 sm:p-6 bg-base-light-200 dark:bg-base-dark-850 sm:justify-center sticky">
            <div class="md:flex md:justify-around">
              <div class="flex justify-center mb-6 md:mb-0">
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
                    <li>
                      <a href="/docs/guides/ash/latest/how_to/contribute" class="hover:underline">Contribute</a>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </footer>
        {/if}
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

  def handle_event("dismiss_catalogue_call_to_action", _, socket) do
    {:noreply,
     socket
     |> assign(:show_catalogue_call_to_action, false)
     |> push_event("catalogue-call-to-action-dismissed", %{})}
  end

  def handle_event("remove_version", %{"library" => library}, socket) do
    new_selected_versions = Map.put(socket.assigns.selected_versions, library, "")

    {:noreply,
     socket
     |> set_selected_library_versions(new_selected_versions)}
  end

  def handle_event("add_version", %{"library" => library}, socket) do
    new_selected_versions = Map.put(socket.assigns.selected_versions, library, "latest")

    {:noreply,
     socket
     |> set_selected_library_versions(new_selected_versions)}
  end

  def handle_event("change-versions", %{"versions" => versions}, socket) do
    {:noreply,
     socket
     |> set_selected_library_versions(versions)}
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

  def mount(_params, session, socket) do
    socket = assign(socket, :page_title, "Ash Framework")

    socket =
      assign_new(socket, :user_agent, fn _assigns ->
        get_connect_params(socket)["user_agent"]
      end)

    socket = assign(socket, :device_brand, "Apple")

    socket = Context.put(socket, platform: socket.assigns.platform)
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

    versions_query =
      AshHq.Docs.LibraryVersion
      |> Ash.Query.sort(version: :desc)

    libraries = AshHq.Docs.Library.read!(load: [versions: versions_query])

    selected_versions =
      Enum.reduce(libraries, configured_library_versions, fn library, acc ->
        if library.name == "ash" do
          Map.put_new(acc, library.id, "latest")
        else
          Map.put_new(acc, library.id, "")
        end
      end)

    {:ok,
     socket
     |> assign(
       :show_catalogue_call_to_action,
       session["catalogue_call_to_action_dismissed"] != "true"
     )
     |> assign(:libraries, libraries)
     |> assign(
       :selected_versions,
       selected_versions
     )
     |> assign(
       :selected_types,
       selected_types
     )
     |> assign(configured_theme: configured_theme)
     |> set_selected_library_versions(selected_versions)
     |> push_event("selected_types", %{types: selected_types})}
  end

  defp set_selected_library_versions(socket, library_versions) do
    socket
    |> assign(:selected_versions, library_versions)
    |> push_event("selected-versions", library_versions)
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

  def toggle_catalogue(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#catalogue-box",
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
    |> JS.dispatch("phx:js:scroll-to", detail: %{id: "catalogue-box"})
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

  def close_catalogue(js \\ %JS{}) do
    js
    |> JS.hide(
      transition: "fade-out",
      to: "#catalogue-box"
    )
  end
end
