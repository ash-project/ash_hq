defmodule AshHqWeb.AuthAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :ash_hq

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
