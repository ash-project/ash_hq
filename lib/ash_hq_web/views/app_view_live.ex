defmodule AshHqWeb.AppViewLive do
  # credo:disable-for-this-file Credo.Check.Readability.MaxLineLength
  use Surface.LiveView,
    container: {:div, class: "h-full"}

  alias AshHqWeb.Components.Search
  alias AshHqWeb.Components.AppView.TopBar
  alias AshHqWeb.Pages.{Docs, Home, LogIn, Register, ResetPassword, UserSettings}
  alias Phoenix.LiveView.JS
  alias Surface.Components.Context
  require Ash.Query

  data configured_theme, :string, default: :system
  data searching, :boolean, default: false
  data selected_versions, :map, default: %{}
  data libraries, :list, default: []
  data selected_types, :map, default: %{}
  data sidebar_state, :map, default: %{}
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
          "h-screen w-screen bg-white dark:bg-base-dark-900 dark:text-white flex flex-col items-stretch",
          "overflow-y-auto overflow-x-hidden": @live_action == :home,
          "overflow-hidden": @live_action == :docs_dsl
        }
      >
        <TopBar
          live_action={@live_action}
          toggle_theme="toggle_theme"
          configured_theme={@configured_theme}
        />
        {#for flash <- List.wrap(live_flash(@flash, :error))}
          <p class="alert alert-warning" role="alert">{flash}</p>
        {/for}
        {#for flash <- List.wrap(live_flash(@flash, :info))}
          <p class="alert alert-info max-h-min" role="alert">{flash}</p>
        {/for}
        {#case @live_action}
          {#match :home}
            <Home id="home" />
          {#match :docs_dsl}
            <Docs
              id="docs"
              uri={@uri}
              params={@params}
              change_version="change_version"
              remove_version="remove_version"
              add_version="add_version"
              sidebar_state={@sidebar_state}
              change_versions="change-versions"
              selected_versions={@selected_versions}
              libraries={@libraries}
            />
          {#match :user_settings}
            <UserSettings id="user_settings" current_user={@current_user} />
          {#match :log_in}
            <LogIn id="log_in" />
          {#match :register}
            <Register id="register" />
          {#match :reset_password}
            <ResetPassword id="reset_password" params={@params} />
        {/case}
      </div>
    </div>
    """
  end

  # defp toggle_account_dropdown(js \\ %JS{}) do
  #   js
  #   |> JS.toggle(
  #     to: "#account-dropdown",
  #     in: {
  #       "transition ease-out duration-100",
  #       "opacity-0 scale-95",
  #       "opacity-100 scale-100"
  #     },
  #     out: {
  #       "transition ease-in duration-75",
  #       "opacity-100 scale-100",
  #       "opacity-0 scale-05"
  #     }
  #   )
  # end

  # {#if @current_user}
  #   <div class="relative inline-block text-left">
  #     <div>
  #       <button
  #         phx-click={toggle_account_dropdown()}
  #         type="button"
  #         class="inline-flex items-center justify-center w-full rounded-md shadow-sm font-medium dark:text-base-dark-400 dark:hover:text-base-dark-200 hover:text-base-dark-600"
  #         id="menu-button"
  #         aria-expanded="true"
  #         aria-haspopup="true"
  #       >
  #         Account
  #         <Heroicons.Solid.ChevronDownIcon class="-mr-1 ml-2 h-5 w-5" />
  #       </button>
  #     </div>

  #     <div
  #       id="account-dropdown"
  #       style="display: none;"
  #       class="origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white dark:text-white dark:bg-base-dark-900 ring-1 ring-black ring-opacity-5 divide-y divide-base-light-100 focus:outline-none"
  #       role="menu"
  #       aria-orientation="vertical"
  #       aria-labelledby="menu-button"
  #       tabindex="-1"
  #       phx-click-away={toggle_account_dropdown()}
  #     >
  #       <div class="py-1" role="none">
  #         <!-- Active: "bg-base-light-100 text-base-light-900", Not Active: "text-base-light-700" -->
  #         <LiveRedirect
  #           to={Routes.app_view_path(AshHqWeb.Endpoint, :user_settings)}
  #           class="dark:text-white group flex items-center px-4 py-2 text-sm"
  #         >
  #           <Heroicons.Solid.PencilAltIcon class="mr-3 h-5 w-5 text-base-light-400 group-hover:text-base-light-500" />
  #           Settings
  #         </LiveRedirect>
  #       </div>
  #       <div class="py-1" role="none">
  #         <Link
  #           label="logout"
  #           to={Routes.user_session_path(AshHqWeb.Endpoint, :delete)}
  #           class="dark:text-white group flex items-center px-4 py-2 text-sm"
  #           method={:delete}
  #           id="logout-link"
  #         >
  #           <Heroicons.Outline.LogoutIcon class="mr-3 h-5 w-5 text-base-light-400 group-hover:text-base-light-500" />
  #           Logout
  #         </Link>
  #       </div>
  #     </div>
  #   </div>
  # {#else}
  #   <LiveRedirect to={Routes.app_view_path(AshHqWeb.Endpoint, :log_in)}>
  #     Sign In
  #   </LiveRedirect>
  # {/if}

  def handle_params(params, uri, socket) do
    {:noreply,
     socket
     |> assign(params: params, uri: uri)}
  end

  def handle_event("remove_version", %{"library" => library}, socket) do
    new_selected_versions = Map.put(socket.assigns.selected_versions, library, "")

    {:noreply,
     socket
     |> assign(:selected_versions, new_selected_versions)
     |> push_event("selected-versions", new_selected_versions)}
  end

  def handle_event("add_version", %{"library" => library}, socket) do
    new_selected_versions = Map.put(socket.assigns.selected_versions, library, "latest")

    send_update(AshHqWeb.Components.VersionPills,
      id: "mobile-sidebar-version-pills",
      action: :close_add_version
    )

    send_update(AshHqWeb.Components.VersionPills,
      id: "sidebar-version-pills",
      action: :close_add_version
    )

    {:noreply,
     socket
     |> assign(:selected_versions, new_selected_versions)
     |> push_event("selected-versions", new_selected_versions)}
  end

  def handle_event("change-versions", %{"versions" => versions}, socket) do
    {:noreply,
     socket
     |> assign(:selected_versions, versions)
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

  def mount(_params, session, socket) do
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
      Enum.reduce(libraries, configured_library_versions, fn library, acc ->
        if library.name == "ash" do
          Map.put_new(acc, library.id, "latest")
        else
          Map.put_new(acc, library.id, "")
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
     |> assign(:selected_versions, selected_versions)
     |> assign(configured_theme: configured_theme, sidebar_state: sidebar_state)
     |> push_event("selected-versions", selected_versions)
     |> push_event("selected_types", %{types: selected_types})}
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
