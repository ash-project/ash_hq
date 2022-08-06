defmodule AshHq.Accounts.User.Changes.CreateEmailConfirmationToken do
  @moduledoc "A change that triggers an email token build and an email notification"

  use Ash.Resource.Change

  def create_email_confirmation_token, do: {__MODULE__, []}

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn changeset, user ->
      AshHq.Accounts.UserToken
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_create(:build_email_token,
        email: user.email,
        context: "confirm",
        sent_to: user.email,
        user: user
      )
      |> AshHq.Accounts.create(return_notifications?: true)
      |> case do
        {:ok, email_token, notifications} ->
          {:ok,
           %{
             user
             | __metadata__:
                 Map.put(user.__metadata__, :token, email_token.__metadata__.url_token)
           }, Enum.map(notifications, &set_metadata(&1, user, changeset, email_token))}

        {:error, error} ->
          {:error, error}
      end
    end)
  end

  defp set_metadata(notification, user, changeset, email_token) do
    url =
      case Ash.Changeset.get_argument(changeset, :confirmation_url_fun) do
        nil ->
          nil

        fun ->
          fun.(email_token.__metadata__.url_token)
      end

    %{
      notification
      | metadata: %{
          user: user,
          url: url,
          confirm?: true
        }
    }
  end
end
