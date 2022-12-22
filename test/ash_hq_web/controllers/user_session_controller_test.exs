defmodule AshHqWeb.UserSessionControllerTest do
  use AshHqWeb.ConnCase, async: true

  import AshHq.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/new_session/:token" do
    test "logs the user in", %{conn: conn, user: user} do
      token = AshHqWeb.UserAuth.create_token_for_user(user)

      conn =
        post(conn, Routes.user_session_path(conn, :log_in), %{
          "log_in" => %{"token" => Base.url_encode64(token, padding: false)}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) =~ "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)

      assert response =~ "Ash Framework"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      token = AshHqWeb.UserAuth.create_token_for_user(user)

      conn =
        post(conn, Routes.user_session_path(conn, :log_in), %{
          "log_in" => %{
            "token" => Base.url_encode64(token, padding: false),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_reference_live_app_web_user_remember_me"]
      assert redirected_to(conn) =~ "/"
    end
  end

  describe "POST /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> post(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns[:flash], :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = post(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns[:flash], :info) =~ "Logged out successfully"
    end
  end
end
