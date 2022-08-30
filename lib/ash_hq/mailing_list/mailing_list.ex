defmodule AshHq.MailingList do
  @moduledoc """
  Handles documentation data.
  """
  use Ash.Api, otp_app: :ash_hq

  resources do
    registry AshHq.MailingList.Registry
  end
end
