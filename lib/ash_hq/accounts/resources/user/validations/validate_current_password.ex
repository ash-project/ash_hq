defmodule AshHq.Accounts.User.Validations.ValidateCurrentPassword do
  @moduledoc """
  Confirms that the provided password is valid.

  This is useful for actions that should only be able to be taken on a given user if you know
  their password (like changing the email, for example).
  """
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, opts) do
    strategy = AshAuthentication.Info.strategy!(changeset.resource, :password)
    plaintext_password = Ash.Changeset.get_argument(changeset, opts[:argument])

    hashed_password = Map.get(changeset.data, strategy.hashed_password_field)

    if hashed_password do
      if strategy.hash_provider.valid?(plaintext_password, hashed_password) do
        :ok
      else
        {:error, [field: opts[:argument], message: "is incorrect"]}
      end
    else
      {:error,
       [
         field: opts[:argument],
         message:
           "has not been set. If you logged in with github and would like to set a password, please log out and use the forgot password flow."
       ]}
    end
  end
end
