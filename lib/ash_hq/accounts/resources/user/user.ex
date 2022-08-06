defmodule AshHq.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer

  alias AshHq.Accounts.Preparations, warn: false
  alias AshHq.Accounts.User.Preparations, as: UserPreparations, warn: false
  alias AshHq.Accounts.User.Changes, warn: false
  alias AshHq.Accounts.User.Validations, warn: false

  identities do
    identity :unique_email, [:email]
  end

  postgres do
    table "users"
    repo AshHq.Repo
  end

  actions do
    defaults [:read]

    read :by_email_and_password do
      argument :email, :string, allow_nil?: false, sensitive?: true
      argument :password, :string, allow_nil?: false, sensitive?: true

      prepare UserPreparations.ValidatePassword

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

      prepare Preparations.SetHashedToken
      prepare Preparations.DetermineDaysForToken

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
          max_length: 80,
          min_length: 12
        ]

      change Changes.HashPassword
    end

    update :deliver_user_confirmation_instructions do
      accept []

      argument :confirmation_url_fun, :function do
        constraints arity: 1
      end

      validate attribute_equals(:confirmed_at, nil), message: "already confirmed"
      change Changes.CreateEmailConfirmationToken
    end

    update :deliver_update_email_instructions do
      accept [:email]

      argument :current_password, :string, allow_nil?: false

      argument :update_url_fun, :function do
        constraints arity: 1
      end

      validate Validations.ValidateCurrentPassword
      validate changing(:email)

      change prevent_change(:email)
      change Changes.CreateEmailUpdateToken
    end

    update :deliver_user_reset_password_instructions do
      accept []

      argument :reset_password_url_fun, :function do
        constraints arity: 1
      end

      change Changes.CreateResetPasswordToken
    end

    update :logout do
      accept []

      change Changes.RemoveAllTokens
    end

    update :change_email do
      accept []
      argument :token, :url_encoded_binary

      change Changes.GetEmailFromToken
      change Changes.DeleteEmailChangeTokens
    end

    update :change_password do
      accept []

      argument :password, :string,
        allow_nil?: false,
        constraints: [
          max_length: 80,
          min_length: 12
        ]

      argument :password_confirmation, :string, allow_nil?: false
      argument :current_password, :string

      validate confirm(:password, :password_confirmation)
      validate Validations.ValidateCurrentPassword

      change Changes.HashPassword
      change Changes.RemoveAllTokens
    end

    update :confirm do
      accept []
      argument :delete_confirm_tokens, :boolean, default: false

      change set_attribute(:confirmed_at, &DateTime.utc_now/0)
      change Changes.DeleteConfirmTokens
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
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_one :token, AshHq.Accounts.UserToken,
      destination_field: :user_id,
      private?: true
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/, "must have the @ sign and no spaces")
  end
end
