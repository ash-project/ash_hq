defmodule AshHq.Accounts.UserToken do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication.TokenResource]

  actions do
    defaults [:read, :destroy]

    read :email_token_for_user do
      get? true

      argument :user_id, :uuid do
        allow_nil? false
      end

      prepare build(sort: [updated_at: :desc], limit: 1)

      filter expr(purpose == "confirm" and not is_nil(extra_data[:email]))
    end
  end

  token do
    api AshHq.Accounts
  end

  relationships do
    belongs_to :user, AshHq.Accounts.User
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      description """
      There are currently no usages of user tokens resource that should be publicly
      accessible, they should all be using authorize?: false.
      """

      forbid_if always()
    end
  end

  postgres do
    table "user_tokens"
    repo AshHq.Repo

    references do
      reference :user, on_delete: :delete, on_update: :update
    end
  end

  code_interface do
    define_for AshHq.Accounts
    define :destroy
    define :email_token_for_user, args: [:user_id]
  end

  resource do
    description """
    Represents a token allowing a user to log in, reset their password, or confirm their email.
    """
  end

  identities do
    identity :token_context, [:context, :token]
  end

  changes do
    change fn changeset, _ ->
             case changeset.context[:ash_authentication][:user] do
               nil ->
                 changeset

               user ->
                 Ash.Changeset.manage_relationship(changeset, :user, user,
                   type: :append_and_remove
                 )
             end
           end,
           on: [:create]
  end
end
