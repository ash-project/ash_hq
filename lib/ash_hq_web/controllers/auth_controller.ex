defmodule AshHqWeb.AuthController do
  use AshHqWeb, :controller
  use AshAuthentication.Phoenix.Controller

  require Logger

  def success(conn, _activity, user, _token) do
    return_to = get_session(conn, :return_to) || "/"

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_user, user)
    |> redirect(to: return_to)
  end

  def failure(
        conn,
        {:password, :sign_in},
        %AshAuthentication.Errors.AuthenticationFailed{}
      ) do
    conn
    |> put_flash(
      :error,
      "Username or password is incorrect"
    )
    |> redirect(to: "/sign-in")
  end

  def failure(conn, activity, reason) do
    stacktrace =
      case reason do
        %{stacktrace: %{stacktrace: stacktrace}} -> stacktrace
        _ -> nil
      end

    Logger.error("""
    Something went wrong in authentication

    activity: #{inspect(activity)}

    reason: #{Exception.format(:error, reason, stacktrace || [])}
    """)

    conn
    |> put_flash(
      :error,
      "Something went wrong"
    )
    |> redirect(to: "/sign-in")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || "/"

    token = Plug.Conn.get_session(conn, "user_token")

    if token do
      AshHq.Accounts.UserToken
      |> AshAuthentication.TokenResource.Actions.get_token(%{"token" => token})
      |> case do
        {:ok, [token]} ->
          AshHq.Accounts.UserToken.destroy!(token, authorize?: false)

        _ ->
          :ok
      end
    end

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end
end
