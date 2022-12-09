defmodule AshHq.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource]

  token do
    api AshHq.Accounts
  end

  postgres do
    table "tokens"
    repo AshHq.Repo
  end
end
