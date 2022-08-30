defmodule AshHq.Accounts do
  @moduledoc """
  Handles user and user token related operations/state
  """
  use Ash.Api, otp_app: :ash_hq

  authorization do
    authorize :by_default
  end

  resources do
    registry AshHq.Accounts.Registry
  end
end
