defmodule AshHq.Accounts.User.Validations.ValidateCurrentPassword do
  @moduledoc """
  Confirms that the provided password is valid.

  This is useful for actions that should only be able to be taken on a given user if you know
  their password (like changing the email, for example).
  """
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _) do
    password = Ash.Changeset.get_argument(changeset, :current_password)

    if AshHq.Accounts.User.Helpers.valid_password?(changeset.data, password) do
      :ok
    else
      {:error, [field: :password, message: "is incorrect"]}
    end
  end
end
