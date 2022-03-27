defmodule AshHqWeb.Router do
  use AshHqWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {AshHqWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AshHqWeb.SessionPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AshHqWeb do
    pipe_through :browser

    live_session :main, root_layout: {AshHqWeb.LayoutView, "root.html"} do
      live "/", AppViewLive, :home
      live "/docs/", AppViewLive, :docs_dsl
      live "/docs/dsl/:library/:version", AppViewLive, :docs_dsl
      live "/docs/dsl/:library/:version/:extension", AppViewLive, :docs_dsl
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", AshHqWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AshHqWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
