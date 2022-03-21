defmodule AshHq.Repo do
  use Ecto.Repo,
    otp_app: :ash_hq,
    adapter: Ecto.Adapters.Postgres
end
