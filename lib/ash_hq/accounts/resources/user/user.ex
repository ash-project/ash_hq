defmodule AshHq.Accounts.User do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  alias AshHq.Accounts.Preparations, warn: false

  actions do
    defaults [:read]

    read :by_email_and_password do
      argument :email, :string, allow_nil?: false, sensitive?: true
      argument :password, :string, allow_nil?: false, sensitive?: true

      prepare AshHq.Accounts.User.Preparations.ValidatePassword

      filter expr(email == ^arg(:email))
    end

    read :by_token do
      argument :token, :url_encoded_binary, allow_nil?: false
      argument :context, :string, allow_nil?: false
      prepare Preparations.DetermineDaysForToken

      filter expr(
               token.token == ^arg(:token) and token.context == ^arg(:context) and
                 token.created_at > ago(^context(:days_for_token), :day)
             )
    end

    read :with_verified_email_token do
      argument :token, :url_encoded_binary, allow_nil?: false
      argument :context, :string, allow_nil?: false

      prepare AshHq.Accounts.Preparations.SetHashedToken
      prepare AshHq.Accounts.Preparations.DetermineDaysForToken

      filter expr(
               token.created_at > ago(^context(:days_for_token), :day) and
                 token.token == ^context(:hashed_token) and token.context == ^arg(:context) and
                 token.sent_to == email
             )
    end

    create :register do
      accept [:email]

      argument :password, :string,
        allow_nil?: false,
        constraints: [
          min_length: 6
        ]

      argument :confirm, :boolean, default: true

      argument :confirmation_url_fun, :function do
        constraints arity: 1
      end

      change AshHq.Accounts.User.Changes.HashPassword
      change {AshHq.Accounts.User.Changes.CreateEmailConfirmationToken, on_argument: :confirm}
    end

    update :deliver_user_confirmation_instructions do
      accept []

      argument :confirmation_url_fun, :function do
        constraints arity: 1
      end

      validate attribute_equals(:confirmed_at, nil), message: "already confirmed"
      change AshHq.Accounts.User.Changes.CreateEmailConfirmationToken
    end

    update :deliver_update_email_instructions do
      accept [:email]

      argument :current_password, :string, allow_nil?: false

      argument :update_url_fun, :function do
        constraints arity: 1
      end

      validate AshHq.Accounts.User.Validations.ValidateCurrentPassword
      validate changing(:email)

      change prevent_change(:email)
      change AshHq.Accounts.User.Changes.CreateEmailUpdateToken
    end

    update :deliver_user_reset_password_instructions do
      accept []

      argument :reset_password_url_fun, :function do
        constraints arity: 1
      end

      change AshHq.Accounts.User.Changes.CreateResetPasswordToken
    end

    update :logout do
      accept []

      change AshHq.Accounts.User.Changes.RemoveAllTokens
    end

    update :change_email do
      accept []
      argument :token, :url_encoded_binary

      change AshHq.Accounts.User.Changes.GetEmailFromToken
      change AshHq.Accounts.User.Changes.DeleteEmailChangeTokens
    end

    update :update_merch_settings do
      argument :address, :string
      argument :name, :string

      accept [:shirt_size]
      change set_attribute(:encrypted_address, arg(:address))
      change set_attribute(:encrypted_name, arg(:name))
    end

    update :change_password do
      accept []

      argument :password, :string,
        allow_nil?: false,
        constraints: [
          min_length: 6
        ]

      argument :password_confirmation, :string, allow_nil?: false
      argument :current_password, :string

      validate confirm(:password, :password_confirmation)
      validate AshHq.Accounts.User.Validations.ValidateCurrentPassword

      change AshHq.Accounts.User.Changes.HashPassword
      change AshHq.Accounts.User.Changes.RemoveAllTokens
    end

    update :reset_password do
      accept []

      argument :password, :string,
        allow_nil?: false,
        constraints: [
          min_length: 6
        ]

      argument :password_confirmation, :string, allow_nil?: false

      validate confirm(:password, :password_confirmation)

      change AshHq.Accounts.User.Changes.HashPassword
      change AshHq.Accounts.User.Changes.RemoveAllTokens
    end

    update :confirm do
      accept []
      argument :delete_confirm_tokens, :boolean, default: false

      change set_attribute(:confirmed_at, &DateTime.utc_now/0)
      change AshHq.Accounts.User.Changes.DeleteConfirmTokens
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string,
      allow_nil?: false,
      constraints: [
        max_length: 160
      ]

    attribute :confirmed_at, :utc_datetime_usec

    attribute :hashed_password, :string, private?: true

    attribute :encrypted_name, AshHq.Types.EncryptedString
    attribute :encrypted_address, AshHq.Types.EncryptedString
    attribute :shirt_size, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  calculations do
    calculate :address, :string, decrypt(:encrypted_address)
    calculate :name, :string, decrypt(:encrypted_name)
  end

  identities do
    identity :unique_email, [:email]
  end

  postgres do
    table "users"
    repo AshHq.Repo
  end

  policies do
    policy action(:read) do
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:change_password) do
      description "Allow the user to change their own password"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:deliver_update_email_instructions) do
      description "Allow a user to request an update their own email"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:by_email_and_password) do
      description "Allow looking up by email/password combo (logging in) for unauthenticated users only."
      forbid_if actor_present()
      authorize_if always()
    end

    policy action(:deliver_user_confirmation_instructions) do
      description "A logged in user can request email confirmation for themselves to be sent again"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:update_merch_settings) do
      description "A logged in user can update their merch settings"
      authorize_if expr(id == ^actor(:id))
    end

    policy action(:register) do
      description "Allow looking up by email/password combo (logging in) for unauthenticated users only."
      forbid_if actor_present()
      authorize_if always()
    end
  end

  relationships do
    has_one :token, AshHq.Accounts.UserToken do
      destination_attribute :user_id
      private? true
    end
  end

  resource do
    description """
    Represents the user of a system.
    """
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/), message: "must have the @ sign and no spaces"
  end
end
