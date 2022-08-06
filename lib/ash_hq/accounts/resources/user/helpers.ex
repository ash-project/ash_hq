defmodule AshHq.Accounts.User.Helpers do
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  def days_for_token("reset_password"), do: @reset_password_validity_in_days
  def days_for_token("confirm"), do: @confirm_validity_in_days
  def days_for_token("session"), do: @session_validity_in_days
  def days_for_token("change:" <> _), do: @change_email_validity_in_days

  def valid_password?(%AshHq.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()

    false
  end
end
