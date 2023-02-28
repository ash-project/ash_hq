defmodule AshHqWeb.Router do
  use AshHqWeb, :router
  use AshAuthentication.Phoenix.Router

  import AshAdmin.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AshHqWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(AshHqWeb.SessionPlug)
    plug(:load_from_session)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:load_from_bearer)
  end

  pipeline :admin_basic_auth do
    plug(:basic_auth)
  end

  scope "/", AshHqWeb do
    pipe_through(:browser)
    reset_route([])

    sign_in_route(
      overrides: [AshHqWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
    )

    sign_out_route(AuthController)
    auth_routes_for(AshHq.Accounts.User, to: AuthController)
  end

  scope "/", AshHqWeb do
    pipe_through(:browser)

    ash_authentication_live_session :main,
      on_mount: [
        {AshHqWeb.LiveUserAuth, :live_user_optional},
        {AshHqWeb.InitAssigns, :default}
      ],
      session: {AshAuthentication.Phoenix.LiveSession, :generate_session, []},
      root_layout: {AshHqWeb.LayoutView, :root} do
      live("/", AppViewLive, :home)
      live("/media", AppViewLive, :media)
      live("/blog", AppViewLive, :blog)
      live("/blog/:slug", AppViewLive, :blog)
      live("/forum", AppViewLive, :forum)
      live("/forum/:channel", AppViewLive, :forum)
      live("/forum/:channel/:id", AppViewLive, :forum)
      live("/docs/", AppViewLive, :docs_dsl)
      live("/docs/guides/:library/:version/*guide", AppViewLive, :docs_dsl)
      live("/docs/dsl/:dsl_target", AppViewLive, :docs_dsl)
      live("/docs/dsl/:library/:version", AppViewLive, :docs_dsl)
      live("/docs/dsl/:library/:version/:extension", AppViewLive, :docs_dsl)
      live("/docs/module/:library/:version/:module", AppViewLive, :docs_dsl)
      live("/docs/mix_task/:library/:version/:mix_task", AppViewLive, :docs_dsl)
      live("/docs/:library/:version", AppViewLive, :docs_dsl)

      get("/docs/dsl/:library/:version/:extension/*dsl_path", DslRedirectController, :show)

      get("/unsubscribe", MailingListController, :unsubscribe)
    end

    ash_authentication_live_session :authenticated_only,
      on_mount: [
        {AshHqWeb.InitAssigns, :default},
        {AshHqWeb.LiveUserAuth, :live_user_required}
      ],
      session: {AshAuthentication.Phoenix.LiveSession, :generate_session, []},
      root_layout: {AshHqWeb.LayoutView, :root} do
      live("/users/settings", AppViewLive, :user_settings)
    end
  end

  get("/rss", AshHqWeb.RssController, :rss)

  ## Api routes
  scope "/" do
    forward("/gql", Absinthe.Plug, schema: AshHqWeb.Schema)

    forward(
      "/playground",
      Absinthe.Plug.GraphiQL,
      schema: AshHqWeb.Schema,
      interface: :playground
    )
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
      pipe_through([:browser])
    else
      pipe_through([:browser, :admin_basic_auth])
    end

    ash_admin("/admin")

    live_dashboard("/dashboard",
      metrics: AshHqWeb.Telemetry,
      ecto_repos: [AshHq.Repo],
      ecto_psql_extras_options: [long_running_queries: [threshold: "200 milliseconds"]]
    )
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  defp basic_auth(conn, _opts) do
    username = System.fetch_env!("ADMIN_AUTH_USERNAME")
    password = System.fetch_env!("ADMIN_AUTH_PASSWORD")
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
