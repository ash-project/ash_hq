defmodule AshHq.Accounts.User.Senders.SendPasswordResetEmail do
  use AshAuthentication.Sender
  use AshHqWeb, :verified_routes

  def send(user, token, _) do
    AshHq.Accounts.Emails.deliver_reset_password_instructions(
      user,
      ~p"/password-reset/#{token}"
    )
  end
end
