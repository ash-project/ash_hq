defmodule AshHq.Accounts.User.Changes.DeleteEmailChangeTokens do
  @moduledoc "A change that deletes all email change tokens for a user"
  use Ash.Resource.Change
  require Ash.Query

  def change(original_changeset, _opts, _context) do
    Ash.Changeset.after_action(original_changeset, fn changeset, user ->
      email = original_changeset.data.email
      context = "change:#{email}"

      token = Ash.Changeset.get_argument(changeset, :token)

      {:ok, query} =
        AshHq.Accounts.UserToken
        |> Ash.Query.filter(token == ^token and context == ^context)
        |> Ash.Query.data_layer_query()

      AshHq.Repo.delete_all(query)

      {:ok, user}
    end)
  end
end
