defmodule AshHqWeb.UserConfirmationController do
  use AshHqWeb, :controller

  alias AshHq.Accounts
  require Ash.Query

  def create(conn, %{"user" => %{"email" => email}}) do
    user =
      AshHq.Accounts.User
      |> Ash.Query.filter(email == ^email)
      |> AshHq.Accounts.read_one!(authorize?: false)

    if user do
      user
      |> Ash.Changeset.for_update(
        :deliver_user_confirmation_instructions,
        %{
          confirmation_url_fun: &Routes.user_confirmation_url(conn, :confirm, &1)
        },
        authorize?: false
      )
      |> Accounts.update()
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: Routes.app_view_path(AshHqWeb.Endpoint, :home))
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def confirm(conn, %{"token" => token}) do
    result =
      AshHq.Accounts.User
      |> Ash.Query.for_read(:with_verified_email_token, %{token: token, context: "confirm"},
        authorize?: false
      )
      |> AshHq.Accounts.read_one!()
      |> case do
        nil ->
          :error

        user ->
          user
          |> Ash.Changeset.for_update(:confirm, %{delete_confirm_tokens: true, token: token},
            authorize?: false
          )
          |> AshHq.Accounts.update()
      end

    case result do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account confirmed successfully.")
        |> redirect(to: Routes.app_view_path(AshHqWeb.Endpoint, :home))

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: Routes.app_view_path(AshHqWeb.Endpoint, :home))

          %{} ->
            conn
            |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
            |> redirect(to: Routes.app_view_path(AshHqWeb.Endpoint, :home))
        end
    end
  end
end
