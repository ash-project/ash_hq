defmodule AshHq.MailingList do
  @moduledoc """
  Handles documentation data.
  """
  use Ash.Domain, otp_app: :ash_hq

  resources do
    resource AshHq.MailingList.Email
  end
end
