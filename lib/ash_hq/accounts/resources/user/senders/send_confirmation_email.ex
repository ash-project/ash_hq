defmodule AshHq.Accounts.User.Senders.SendConfirmationEmail do
  @moduledoc """
  Sends a confirmation email for initial sign up or email change.
  """
  use AshAuthentication.Sender
  use AshHqWeb, :verified_routes

  def send(user, token, opts) do
    if opts[:changeset] && opts[:changeset].action.name == :update_email do
      AshHq.Accounts.Emails.deliver_update_email_instructions(
        %{user | email: Ash.Changeset.get_attribute(opts[:changeset], :email)},
        AshHqWeb.Routes.url(~p"/auth/user/confirm?confirm=#{token}")
      )
    else
      AshHq.Accounts.Emails.deliver_confirmation_instructions(
        user,
        AshHqWeb.Routes.url(~p"/auth/user/confirm?confirm=#{token}")
      )
    end
  end
end
