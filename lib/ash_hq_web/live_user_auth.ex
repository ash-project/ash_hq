defmodule AshHqWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in liveviews
  """

  @doc """
  Sets the current user on each mount of a liveview
  """
  def on_mount(:live_user, _params, session, socket) do
    {:cont,
     Phoenix.LiveView.assign(
       socket,
       :current_user,
       AshHqWeb.UserAuth.user_for_session_token(session["user_token"])
     )}
  end
end
