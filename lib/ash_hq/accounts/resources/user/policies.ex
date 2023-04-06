defmodule AshHq.Accounts.User.Policies do
  use Spark.Dsl.Fragment, of: Ash.Resource, authorizers: [Ash.Policy.Authorizer]

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:update_email) do
      description "A logged in user can update their email"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:resend_confirmation_instructions) do
      description "A logged in user can request an email confirmation"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:change_password) do
      description "A logged in user can reset their password"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:update_merch_settings) do
      description "A logged in user can update their merch settings"
      authorize_if expr(id == ^actor(:id))
    end
  end
end
