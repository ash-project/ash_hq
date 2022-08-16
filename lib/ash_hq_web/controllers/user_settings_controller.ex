defmodule AshHqWeb.UserSettingsController do
  use AshHqWeb, :controller

  def confirm_email(conn, %{"token" => token}) do
    conn.assigns.current_user
    |> Ash.Changeset.for_update(:change_email, %{token: token}, authorize?: false)
    |> AshHq.Accounts.update()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.app_view_path(conn, :user_settings))

      {:error, _form} ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.app_view_path(conn, :user_settings))
    end
  end
end
