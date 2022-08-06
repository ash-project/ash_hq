defmodule AshHq.Accounts.UserToken.Changes.BuildHashedToken do
  @moduledoc "A change that sets the session token based on the user id"

  use Ash.Resource.Change

  @rand_size 32
  @hash_algorithm :sha256

  def build_hashed_token() do
    {__MODULE__, []}
  end

  def change(changeset, _opts, _context) do
    token = :crypto.strong_rand_bytes(@rand_size)

    hashed_token = :crypto.hash(@hash_algorithm, token)

    changeset
    |> Ash.Changeset.change_attribute(:token, hashed_token)
    |> Ash.Changeset.after_action(fn _changeset, result ->
      metadata =
        Map.put(result.__metadata__, :url_token, Base.url_encode64(token, padding: false))

      {:ok,
       %{
         result
         | __metadata__: metadata
       }}
    end)
  end
end
