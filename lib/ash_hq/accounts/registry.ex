defmodule AshHq.Accounts.Registry do
  @moduledoc false

  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.Accounts.User
    entry AshHq.Accounts.UserToken
  end
end
