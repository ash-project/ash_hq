defmodule AshHq.Docs do
  use Ash.Api, otp_app: :ash_hq

  execution do
    timeout 30_000
  end
end
