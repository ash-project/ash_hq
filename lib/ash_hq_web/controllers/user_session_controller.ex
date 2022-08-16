defmodule AshHqWeb.UserSessionController do
  use AshHqWeb, :controller

  alias AshHqWeb.UserAuth

  def log_in(conn, %{"log_in" => %{"token" => token} = params}) do
    token = Base.url_decode64!(token, padding: false)
    UserAuth.log_in_with_token(conn, token, params["remember_me"] == "true", params["return_to"])
  end

  def log_in(conn, %{"log_in" => %{"email" => email, "password" => password} = params}) do
    AshHq.Accounts.User
    |> Ash.Query.for_read(:by_email_and_password, %{email: email, password: password},
      authorize?: false
    )
    |> AshHq.Accounts.read_one()
    |> case do
      {:ok, nil} ->
        redirect(conn, to: "/")

      {:ok, user} ->
        token = AshHqWeb.UserAuth.create_token_for_user(user)

        UserAuth.log_in_with_token(
          conn,
          token,
          params["remember_me"] == "true",
          params["return_to"]
        )

      {:error, _} ->
        redirect(conn, to: "/")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
