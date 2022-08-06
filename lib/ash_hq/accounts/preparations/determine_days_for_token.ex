defmodule AshHq.Accounts.Preparations.DetermineDaysForToken do
  @moduledoc """
  Sets a `days_for_token` context on the query.

  This corresponds to how many days the token should be considered valid. See `AshHq.Accounts.User.Helpers` for more.
  """
  use Ash.Resource.Preparation

  def prepare(query, _opts, _) do
    Ash.Query.put_context(
      query,
      :days_for_token,
      AshHq.Accounts.User.Helpers.days_for_token(Ash.Query.get_argument(query, :context))
    )
  end
end
