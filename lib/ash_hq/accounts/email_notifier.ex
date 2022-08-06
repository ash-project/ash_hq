defmodule AshHq.Accounts.EmailNotifier do
  def notify(%Ash.Notifier.Notification{
        resource: AshHq.Accounts.UserToken,
        action: %{name: :build_email_token},
        metadata: %{
          user: user,
          url: url,
          confirm?: true
        }
      }) do
    AshHq.Accounts.Emails.deliver_confirmation_instructions(user, url)
  end

  def notify(%Ash.Notifier.Notification{
        resource: AshHq.Accounts.UserToken,
        action: %{name: :build_email_token},
        metadata: %{
          user: user,
          url: url,
          update?: true
        }
      }) do
    AshHq.Accounts.Emails.deliver_update_email_instructions(user, url)
  end

  def notify(%Ash.Notifier.Notification{
        resource: AshHq.Accounts.UserToken,
        action: %{name: :build_email_token},
        metadata: %{
          user: user,
          url: url,
          reset?: true
        }
      }) do
    AshHq.Accounts.Emails.deliver_reset_password_instructions(user, url)
  end

  def notify(_other) do
    :ok
  end
end
