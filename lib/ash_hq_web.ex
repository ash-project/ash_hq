defmodule AshHqWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use AshHqWeb, :controller
      use AshHqWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def verified_routes do
    quote do
      unquote(use_verified_routes())
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: AshHqWeb

      import Plug.Conn
      import AshHqWeb.Gettext
      alias AshHqWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/ash_hq_web/templates",
        namespace: AshHqWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {AshHqWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component
      import AshHqWeb.Tails

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import AshHqWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      import Phoenix.HTML
      import Phoenix.HTML.Form
      use PhoenixHTMLHelpers

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView.Helpers
      import Phoenix.Component

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import AshHqWeb.ErrorHelpers
      import AshHqWeb.Gettext
      alias AshHqWeb.Router.Helpers, as: Routes
      unquote(use_verified_routes())
    end
  end

  @spec use_verified_routes :: Macro.t()
  def use_verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: AshHqWeb.Endpoint,
        router: AshHqWeb.Router,
        statics: AshHqWeb.static_paths()
    end
  end

  def static_paths do
    ~w(assets fonts images favicon.ico robots.txt)
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
