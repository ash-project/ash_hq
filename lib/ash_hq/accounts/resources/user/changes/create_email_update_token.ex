defmodule AshHq.Accounts.User.Changes.CreateEmailUpdateToken do
  @moduledoc "A change that triggers an email token build and an email notification"

  use Ash.Resource.Change

  def change(original_changeset, _opts, _context) do
    Ash.Changeset.after_action(original_changeset, fn changeset, user ->
      AshHq.Accounts.UserToken
      |> Ash.Changeset.for_create(
        :build_email_token,
        %{
          email: user.email,
          context: "change:#{user.email}",
          sent_to: original_changeset.attributes[:email],
          user: user.id
        },
        authorize?: false
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
      case Ash.Changeset.get_argument(changeset, :update_url_fun) do
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
          update?: true
        }
    }
  end
end
