defmodule AshHqWeb.UserSettingsControllerTest do
  use AshHqWeb.ConnCase, async: true

  alias AshHq.Accounts
  import AshHq.AccountsFixtures

  setup :register_and_log_in_user

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        user
        |> Ash.Changeset.for_update(
          :deliver_update_email_instructions,
          %{
            email: email,
            current_password: valid_user_password()
          },
          authorize?: false
        )
        |> Accounts.update!()
        |> Map.get(:__metadata__)
        |> Map.get(:token)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.app_view_path(conn, :user_settings)
      assert get_flash(conn, :info) =~ "Email changed successfully"

      refute Accounts.get!(Accounts.User, [email: user.email], authorize?: false, error?: false)

      assert Accounts.get!(Accounts.User, [email: email], authorize?: false)

      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.app_view_path(conn, :user_settings)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.app_view_path(conn, :user_settings)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"

      assert Accounts.get!(Accounts.User, [email: user.email], authorize?: false)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.user_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.app_view_path(conn, :log_in)
    end
  end
end
