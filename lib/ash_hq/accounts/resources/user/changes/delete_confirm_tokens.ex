defmodule AshHq.Accounts.User.Changes.DeleteConfirmTokens do
  @moduledoc "A change that deletes all confirm tokens for a user, if the `delete_confirm_tokens` argument is present"
  use Ash.Resource.Change
  require Ash.Query

  def delete_confirm_tokens, do: {__MODULE__, []}

  def change(changeset, _opts, _context) do
    if Ash.Changeset.get_argument(changeset, :delete_confirm_tokens) do
      Ash.Changeset.after_action(changeset, fn _changeset, user ->
        days = AshHq.Accounts.User.Helpers.days_for_token("confirm")

        {:ok, query} =
          AshHq.Accounts.UserToken
          |> Ash.Query.filter(
            created_at > ago(^days, :day) and context == "confirm" and
              sent_to == user.email
          )
          |> Ash.Query.data_layer_query()

        AshHq.Repo.delete_all(query)

        {:ok, user}
      end)
    else
      changeset
    end
  end
end
