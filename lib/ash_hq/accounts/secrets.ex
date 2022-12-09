defmodule AshHq.Accounts.GetSecret do
  def secret_for(secret, MyApp.User, _opts) do
    IO.inspect(secret)
    nil
  end
end
