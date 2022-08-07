defmodule AshHqWeb.UserSessionController do
  use AshHqWeb, :controller

  alias AshHq.Accounts
  alias AshHqWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    Accounts.User
    |> Ash.Query.for_read(:by_email_and_password, user_params)
    |> Accounts.read_one(authorize?: false)
    |> case do
      {:ok, user} when not is_nil(user) ->
        UserAuth.log_in_user(conn, user, user_params)

      _ ->
        render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
