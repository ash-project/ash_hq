defmodule AshHq.Accounts.User.Validations do
  alias AshHq.Accounts.User.Validations

  def validate_current_password() do
    {Validations.ValidateCurrentPassword, []}
  end
end
