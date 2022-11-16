defmodule AshHq.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AshHq.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    params =
      Enum.into(attrs, %{
        email: unique_user_email(),
        password: valid_user_password(),
        confirmation_url_fun:
          &AshHqWeb.Router.Helpers.user_confirmation_url(AshHqWeb.Endpoint, :confirm, &1)
      })

    user =
      AshHq.Accounts.User
      |> Ash.Changeset.for_create(:register, params, authorize?: false)
      |> AshHq.Accounts.create!()

    Swoosh.TestAssertions.assert_email_sent()

    user
  end
end
