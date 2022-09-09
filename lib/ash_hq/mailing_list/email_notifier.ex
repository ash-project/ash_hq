defmodule AshHq.MailingList.EmailNotifier do
  @moduledoc "Sends emails from events in the MailingList api"
  use Ash.Notifier

  def notify(%Ash.Notifier.Notification{
        data: email,
        resource: AshHq.MailingList.Email,
        action: %{type: :create}
      }) do
    if email.updated_at == email.inserted_at do
      AshHq.MailingList.Emails.deliver_welcome_email(email)
    end

    :ok
  end

  def notify(_), do: :ok
end
