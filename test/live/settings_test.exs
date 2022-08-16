defmodule AshHq.SettingsTest do
  use AshHqWeb.ConnCase

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  @endpoint AshHqWeb.Endpoint

  setup :register_and_log_in_user

  describe "change email form" do
    test "renders", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/users/settings")

      assert html =~ "Update Email"
    end

    test "submission shows a flash message", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/users/settings")

      assert {:ok, _view, html} =
               view
               |> element("form#update_email")
               |> render_submit(%{
                 update_email: %{email: "new_email@example.com", current_password: "hello world!"}
               })
               |> follow_redirect(conn)

      assert html =~ "Check your email"
    end

    test "submission sends an email but does not change the email", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/settings")

      view
      |> element("form#update_email")
      |> render_submit(%{
        update_email: %{email: "new_email@example.com", current_password: "hello world!"}
      })

      assert_received {:email, email}

      assert email.subject == "Confirm Your Email Change"
      new_user = AshHq.Accounts.reload!(user, authorize?: false)
      assert new_user.email == user.email
    end

    test "following the link in the email changes the email", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/settings")

      view
      |> element("form#update_email")
      |> render_submit(%{
        update_email: %{email: "new_email@example.com", current_password: "hello world!"}
      })

      assert_received {:email, email}

      assert %{"url" => url} = Regex.named_captures(~r/(?<url>http[^\s]*)/, email.text_body)

      path = URI.parse(url).path

      assert {:ok, _conn} = conn |> live(path) |> follow_redirect(conn, "/users/settings")

      new_user = AshHq.Accounts.reload!(user, authorize?: false)
      assert to_string(new_user.email) == "new_email@example.com"
    end
  end

  describe "change_password" do
    test "renders", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/users/settings")

      assert html =~ "Change Password"
    end

    test "submission shows a flash message", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/users/settings")

      assert {:ok, _view, html} =
               view
               |> element("form#change_password")
               |> render_submit(%{
                 change_password: %{
                   password: "hello world2!",
                   password_confirmation: "hello world2!",
                   current_password: "hello world!"
                 }
               })
               |> follow_redirect(conn)

      assert html =~ "Password has been successfully changed"
    end

    test "submission changes the password", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/settings")

      assert {:ok, _view, html} =
               view
               |> element("form#change_password")
               |> render_submit(%{
                 change_password: %{
                   password: "hello world2!",
                   password_confirmation: "hello world2!",
                   current_password: "hello world!"
                 }
               })
               |> follow_redirect(conn)

      assert html =~ "Password has been successfully changed"

      assert AshHq.Accounts.User
             |> Ash.Query.for_read(:by_email_and_password, %{
               email: user.email,
               password: "hello world2!"
             })
             |> AshHq.Accounts.read_one!(authorize?: false)
    end
  end
end
