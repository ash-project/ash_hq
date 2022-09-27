defmodule AshHq.Accounts.User.Changes.RemoveAllTokens do
  @moduledoc """
  Removes all tokens for a given user.

  Since Ash does not yet support bulk actions, this goes straight to the data layer.
  """
  use Ash.Resource.Change
  require Ash.Query

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, user ->
      {:ok, query} =
        AshHq.Accounts.UserToken
        |> Ash.Query.filter(user_id == ^user.id)
        |> Ash.Query.data_layer_query()

      AshHq.Repo.delete_all(query)

      {:ok, user}
    end)
  end
end
