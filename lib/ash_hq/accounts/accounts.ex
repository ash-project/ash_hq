defmodule AshHq.Accounts do
  @moduledoc """
  Handles user and user token related operations/state
  """
  use Ash.Domain, otp_app: :ash_hq

  resources do
    resource AshHq.Accounts.User
    resource AshHq.Accounts.UserToken
  end
end
