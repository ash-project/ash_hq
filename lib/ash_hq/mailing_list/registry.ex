defmodule AshHq.MailingList.Registry do
  @moduledoc false
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.MailingList.Email
  end
end
