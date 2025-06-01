defmodule AshHqWeb.Router do
  use AshHqWeb, :router

  import AshAdmin.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AshHqWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(AshHqWeb.SessionPlug)
    plug(AshHqWeb.RedirectToHex)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admin_basic_auth do
    plug(:basic_auth)
  end

  scope "/new" do
    get("/:name", AshHqWeb.NewController, :new)
  end

  scope "/install" do
    get("/:name", AshHqWeb.NewController, :new_no_ash)
  end

  scope "/", AshHqWeb do
    pipe_through(:browser)
    get "/", HomeController, :home
    get "/community", HomeController, :community
    get "/media", HomeController, :media

    get "/book-errata", HomeController, :book_errata

    live("/blog", AppViewLive, :blog)
    live("/blog/:slug", AppViewLive, :blog)
    # live("/community", AppViewLive, :community)
    get "/docs/", HomeController, :home
    get "/docs/guides/:library/:version/*guide", HomeController, :home
    get "/docs/dsl/:dsl_target", HomeController, :home
    get "/docs/dsl/:library/:version", HomeController, :home
    get "/docs/dsl/:library/:version/:extension", HomeController, :home
    get "/docs/module/:library/:version/:module", HomeController, :home
    get "/docs/mix_task/:library/:version/:mix_task", HomeController, :home
    get "/docs/:library/:version", HomeController, :home
    get "/docs/*path", HomeController, :home

    # for showing deprecated forum content
    live("/forum", AppViewLive, :forum)
    live("/forum/:channel", AppViewLive, :forum)
    live("/forum/:channel/:id", AppViewLive, :forum)
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
