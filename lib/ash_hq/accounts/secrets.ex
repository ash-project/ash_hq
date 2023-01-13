defmodule AshHq.Accounts.Secrets do
  @moduledoc "Secrets adapter for AshHq authentication"
  use AshAuthentication.Secret

  @github_secret_keys ~w(client_id client_secret redirect_uri)a

  def secret_for([:authentication, :tokens, :signing_secret], AshHq.Accounts.User, _) do
    Application.fetch_env(:ash_hq, :token_signing_secret)
  end

  def secret_for([:authentication, :strategies, :github, key], AshHq.Accounts.User, _)
      when key in @github_secret_keys do
    with {:ok, value} <- Application.fetch_env(:ash_hq, :github) do
      Keyword.fetch(value, key)
    end
  end
end
