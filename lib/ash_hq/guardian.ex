defmodule AshHq.Guardian do
  use Guardian, otp_app: :ash_hq

  alias AshHq.Accounts

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Accounts.get!(Accounts.User, id)

    {:ok, resource}
  end
end
