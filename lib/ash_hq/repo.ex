defmodule AshHq.Repo do
  use AshPostgres.Repo,
    otp_app: :ash_hq
end
