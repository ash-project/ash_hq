defmodule AshHq.Accounts.User.Changes.CreateResetPasswordToken do
  @moduledoc "A change that triggers an reset password token build and an email notification"

  use Ash.Resource.Change

  def create_reset_password_token, do: {__MODULE__, []}

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn changeset, user ->
      AshHq.Accounts.UserToken
      |> Ash.Changeset.new()
      |> Ash.Changeset.for_create(:build_email_token,
        email: user.email,
        context: "reset_password",
        sent_to: user.email,
        user: user
      )
      |> AshHq.Accounts.create(return_notifications?: true, authorize?: false)
      |> case do
        {:ok, email_token, notifications} ->
          {:ok, %{user | __metadata__: Map.put(user.__metadata__, :token, email_token.token)},
           Enum.map(notifications, &set_metadata(&1, user, changeset, email_token))}

        {:error, error} ->
          {:error, error}
      end
    end)
  end

  defp set_metadata(notification, user, changeset, email_token) do
    url =
      case Ash.Changeset.get_argument(changeset, :reset_password_url_fun) do
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
          reset?: true
        }
    }
  end
end
