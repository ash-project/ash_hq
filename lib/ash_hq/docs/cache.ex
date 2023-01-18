defmodule AshHq.Docs.Cache do
  use Nebulex.Cache,
    otp_app: :ash_hq,
    adapter: Nebulex.Adapters.Local
end
