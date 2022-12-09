defmodule AshHq.Accounts.User do
  @moduledoc false

  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

  actions do
    defaults [:read]

    update :update_merch_settings do
      argument :address, :string
      argument :name, :string

      accept [:shirt_size]
      change set_attribute(:encrypted_address, arg(:address))
      change set_attribute(:encrypted_name, arg(:name))
    end
  end

  authentication do
    api AshHq.Accounts

    strategies do
      password :password do
        identity_field(:email)
      end
    end

    tokens do
      enabled?(true)
      token_resource(AshHq.Accounts.Token)
      signing_secret(AshHq.Accounts.GetSecret)
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

    attribute :hashed_password, :string, private?: true, sensitive?: true

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
