defmodule AshHqWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in liveviews
  """

  alias AshHqWeb.Router.Helpers, as: Routes

  @doc """
  Sets the current user on each mount of a liveview
  """
  def on_mount(:live_user, _params, session, socket) do
    {:cont,
     Phoenix.Component.assign(
       socket,
       :current_user,
       AshHqWeb.UserAuth.user_for_session_token(session["user_token"])
     )}
  end

  def on_mount(:live_user_required, _params, session, socket) do
    case AshHqWeb.UserAuth.user_for_session_token(session["user_token"]) do
      nil ->
        {:halt, Phoenix.LiveView.redirect(socket, to: "/users/log_in")}

      user ->
        {:cont,
         Phoenix.Component.assign(
           socket,
           :current_user,
           user
         )}
    end
  end

  def on_mount(:live_user_not_allowed, _params, session, socket) do
    case AshHqWeb.UserAuth.user_for_session_token(session["user_token"]) do
      nil ->
        {:cont,
         Phoenix.Component.assign(
           socket,
           :current_user,
           nil
         )}

      _user ->
        {:halt,
         Phoenix.LiveView.redirect(socket, to: Routes.app_view_path(AshHqWeb.Endpoint, :home))}
    end
  end
end
