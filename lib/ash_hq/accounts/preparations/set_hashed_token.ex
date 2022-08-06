defmodule AshHq.Accounts.Preparations.SetHashedToken do
  use Ash.Resource.Preparation

  @hash_algorithm :sha256

  def prepare(query, _opts, _) do
    case Ash.Query.get_argument(query, :token) do
      nil ->
        query

      token ->
        Ash.Query.put_context(
          query,
          :hashed_token,
          :crypto.hash(@hash_algorithm, token)
        )
    end
  end
end
