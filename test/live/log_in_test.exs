defmodule AshHq.LogInTest do
  use AshHqWeb.ConnCase

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  @endpoint AshHqWeb.Endpoint

  setup :register_user

  describe "log in form" do
    test "renders", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/users/log_in")

      assert html =~ "Log In"
    end

    test "submission logs you in", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/log_in")

      form = form(view, "form#log_in", log_in: %{email: user.email, password: "hello world!"})

      assert form
             |> render_submit() =~ "phx-trigger-action"

      conn = follow_trigger_action(form, conn)

      conn = fetch_session(conn)
      assert get_session(conn, :user_token)
    end

    test "submission with a bad password does not log you in", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/log_in")

      form = form(view, "form#log_in", log_in: %{email: user.email, password: "bad password!"})

      assert {:ok, _view, html} =
               form
               |> render_submit()
               |> follow_redirect(conn)

      assert html =~ "Invalid username or password"
    end
  end
end
