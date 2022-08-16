# defmodule AshHqWeb.UserResetPasswordControllerTest do
#   use AshHqWeb.ConnCase, async: true

#   alias AshHq.Accounts
#   alias AshHq.Repo
#   import AshHq.AccountsFixtures

#   setup do
#     %{user: user_fixture()}
#   end

#   describe "GET /users/reset_password" do
#     test "renders the reset password page", %{conn: conn} do
#       conn = get(conn, Routes.user_reset_password_path(conn, :new))
#       response = html_response(conn, 200)
#       assert response =~ "Forgot your password?</h5>"
#     end
#   end

#   describe "POST /users/reset_password" do
#     @tag :capture_log
#     test "sends a new reset password token", %{conn: conn, user: user} do
#       conn =
#         post(conn, Routes.user_reset_password_path(conn, :create), %{
#           "user" => %{"email" => user.email}
#         })

#       assert redirected_to(conn) == "/"
#       assert get_flash(conn, :info) =~ "If your email is in our system"
#       assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
#     end

#     test "does not send reset password token if email is invalid", %{conn: conn} do
#       conn =
#         post(conn, Routes.user_reset_password_path(conn, :create), %{
#           "user" => %{"email" => "unknown@example.com"}
#         })

#       assert redirected_to(conn) == "/"
#       assert get_flash(conn, :info) =~ "If your email is in our system"
#       assert Repo.all(Accounts.UserToken) == []
#     end
#   end

#   describe "GET /users/reset_password/:token" do
#     setup %{user: user} do
#       token =
#         user
#         |> Ash.Changeset.for_update(:deliver_user_reset_password_instructions, %{}, authorize?: false)
#         |> Accounts.update!()
#         |> Map.get(:__metadata__)
#         |> Map.get(:token)

#       %{token: token}
#     end

#     test "renders reset password", %{conn: conn, token: token} do
#       conn = get(conn, Routes.user_reset_password_path(conn, :edit, token))
#       assert html_response(conn, 200) =~ "Reset Password</h5>"
#     end

#     test "does not render reset password with invalid token", %{conn: conn} do
#       conn = get(conn, Routes.user_reset_password_path(conn, :edit, "oops"))
#       assert redirected_to(conn) == "/"
#       assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
#     end
#   end

#   describe "PUT /users/reset_password/:token" do
#     setup %{user: user} do
#       token =
#         user
#         |> Ash.Changeset.for_update(:deliver_user_reset_password_instructions, %{}, authorize?: false)
#         |> Accounts.update!()
#         |> Map.get(:__metadata__)
#         |> Map.get(:token)

#       %{token: token}
#     end

#     test "resets password once", %{conn: conn, user: user, token: token} do
#       conn =
#         put(conn, Routes.user_reset_password_path(conn, :update, token), %{
#           "user" => %{
#             "current_password" => "hello world!",
#             "password" => "new valid password",
#             "password_confirmation" => "new valid password"
#           }
#         })

#       assert redirected_to(conn) == Routes.app_view_path(conn, :log_in)
#       refute get_session(conn, :user_token)
#       assert get_flash(conn, :info) =~ "Password reset successfully"

#       assert Accounts.User
#              |> Ash.Query.for_read(:by_email_and_password, %{
#                email: user.email,
#                password: "new valid password"
#              }, authorize?: false)
#              |> Accounts.read_one!()
#     end

#     test "does not reset password on invalid data", %{conn: conn, token: token} do
#       conn =
#         put(conn, Routes.user_reset_password_path(conn, :update, token), %{
#           "user" => %{
#             "password" => "too short",
#             "password_confirmation" => "does not match"
#           }
#         })

#       response = html_response(conn, 200)
#       assert response =~ "Reset Password</h5>"
#       assert response =~ "length must be greater than or equal to 12"
#       assert response =~ "Confirmation did not match value"
#     end

#     test "does not reset password with invalid token", %{conn: conn} do
#       conn = put(conn, Routes.user_reset_password_path(conn, :update, "oops"))
#       assert redirected_to(conn) == "/"
#       assert get_flash(conn, :error) =~ "Reset password link is invalid or it has expired"
#     end
#   end
# end
