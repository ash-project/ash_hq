defmodule AshHq.Accounts.User.Validations.ValidateCurrentPassword do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, _) do
    password = Ash.Changeset.get_argument(changeset, :current_password)

    if AshHq.Accounts.User.Helpers.valid_password?(changeset.data, password) do
      :ok
    else
      {:error, "invalid"}
    end
  end
end
