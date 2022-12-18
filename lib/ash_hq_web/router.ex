defmodule AshHqWeb.Router do
  use AshHqWeb, :router

  import AshHqWeb.UserAuth
  import AshAdmin.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AshHqWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug AshHqWeb.SessionPlug
    plug :assign_user_agent
  end

  pipeline :dead_view_authentication do
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_basic_auth do
    plug :basic_auth
  end

  scope "/", AshHqWeb do
    pipe_through :browser

    live_session :main,
      on_mount: [{AshHqWeb.InitAssigns, :default}, {AshHqWeb.LiveUserAuth, :live_user}],
      root_layout: {AshHqWeb.LayoutView, :root} do
      live "/", AppViewLive, :home
      live "/media", AppViewLive, :media
      live "/blog", AppViewLive, :blog
      live "/blog/:slug", AppViewLive, :blog
      live "/docs/", AppViewLive, :docs_dsl
      live "/docs/guides/:library/:version/*guide", AppViewLive, :docs_dsl
      live "/docs/dsl/:library", AppViewLive, :docs_dsl
      live "/docs/dsl/:library/:version", AppViewLive, :docs_dsl
      live "/docs/dsl/:library/:version/:extension", AppViewLive, :docs_dsl
      live "/docs/dsl/:library/:version/:extension/*dsl_path", AppViewLive, :docs_dsl
      live "/docs/module/:library/:version/:module", AppViewLive, :docs_dsl
      live "/docs/mix_task/:library/:version/:mix_task", AppViewLive, :docs_dsl
      live "/docs/:library/:version", AppViewLive, :docs_dsl

      get "/unsubscribe", MailingListController, :unsubscribe
    end

    live_session :unauthenticated_only,
      on_mount: [
        {AshHqWeb.InitAssigns, :default},
        {AshHqWeb.LiveUserAuth, :live_user_not_allowed}
      ],
      root_layout: {AshHqWeb.LayoutView, :root} do
      live "/users/log_in", AppViewLive, :log_in
      live "/users/register", AppViewLive, :register
      live "/users/reset_password", AppViewLive, :reset_password
      live "/users/reset_password/:token", AppViewLive, :reset_password
    end

    live_session :authenticated_only,
      on_mount: [{AshHqWeb.InitAssigns, :default}, {AshHqWeb.LiveUserAuth, :live_user_required}],
      root_layout: {AshHqWeb.LayoutView, :root} do
      live "/users/settings", AppViewLive, :user_settings
    end
  end

  get "/rss", AshHqWeb.RssController, :rss

  ## Api routes
  scope "/" do
    forward "/gql", Absinthe.Plug, schema: AshHqWeb.Schema

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: AshHqWeb.Schema,
            interface: :playground
  end

  ## Authentication routes

  scope "/", AshHqWeb do
    pipe_through [
      :browser,
      :dead_view_authentication,
      :redirect_if_user_is_authenticated,
      :put_session_layout
    ]

    get "/users/new_session", UserSessionController, :log_in
    post "/users/new_session", UserSessionController, :log_in
  end

  scope "/", AshHqWeb do
    pipe_through [:browser, :dead_view_authentication, :require_authenticated_user]

    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", AshHqWeb do
    pipe_through [:browser, :dead_view_authentication]

    post "/users/log_out", UserSessionController, :delete
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  import Phoenix.LiveDashboard.Router

  scope "/" do
    if Mix.env() in [:dev, :test] do
      pipe_through [:browser, :dead_view_authentication]
    else
      pipe_through [:browser, :admin_basic_auth]
    end

    ash_admin("/admin")

    live_dashboard "/dashboard",
      metrics: AshHqWeb.Telemetry,
      ecto_repos: [AshHq.Repo],
      ecto_psql_extras_options: [long_running_queries: [threshold: "200 milliseconds"]]
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:browser, :dead_view_authentication]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  defp basic_auth(conn, _opts) do
    username = System.fetch_env!("ADMIN_AUTH_USERNAME")
    password = System.fetch_env!("ADMIN_AUTH_PASSWORD")
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  def assign_user_agent(conn, _opts) do
    ua = get_req_header(conn, "user-agent")

    case ua do
      [ua] ->
        assign(conn, :user_agent, ua)

      _ ->
        assign(conn, :user_agent, "")
    end
  end
end
