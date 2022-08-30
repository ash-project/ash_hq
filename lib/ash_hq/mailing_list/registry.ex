defmodule AshHq.MailingList.Registry do
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.MailingList.Email
  end
end
