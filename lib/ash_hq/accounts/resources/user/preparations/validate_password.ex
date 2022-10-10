defmodule AshHq.Accounts.User.Preparations.ValidatePassword do
  @moduledoc """
  Given the result of a query for users, and a password argument, ensures that the `password` is valid.

  If there is more or less than one result, or if the password is invalid, then this removes the results of the query.
  In this way, you can't tell from the outside whether or not the password was invalid or there was no matching account.
  """
  use Ash.Resource.Preparation

  def prepare(query, _opts, _) do
    Ash.Query.after_action(query, fn
      query, [result] ->
        password = Ash.Query.get_argument(query, :password)

        if AshHq.Accounts.User.Helpers.valid_password?(result, password) do
          {:ok, [result]}
        else
          {:ok, []}
        end

      _, _ ->
        Bcrypt.no_user_verify()
        {:ok, []}
    end)
  end
end
