defmodule AshHq.Accounts.User do
  @moduledoc false

  use Ash.Resource,
    domain: AshHq.Accounts,
    data_layer: AshPostgres.DataLayer,
    fragments: [AshHq.Accounts.User.Policies]

  require Ash.Query

  alias AshHq.Calculations.Decrypt

  actions do
    defaults [:read]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string,
      allow_nil?: false,
      constraints: [
        max_length: 160
      ]

    attribute :hashed_password, :string, sensitive?: true

    attribute :encrypted_name, :string
    attribute :encrypted_address, :string
    attribute :shirt_size, :string
    attribute :github_info, :map

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_one :token, AshHq.Accounts.UserToken do
      destination_attribute :user_id
    end
  end

  postgres do
    table "users"
    repo AshHq.Repo
  end

  resource do
    description """
    Represents the user of a system.
    """
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with AshHq.Accounts
    end
  end

  changes do
    change {AshHq.Changes.Encrypt, fields: [:encrypted_address, :encrypted_name]}
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/), message: "must have the @ sign and no spaces"
  end

  calculations do
    calculate :address, :string, {Decrypt, field: :encrypted_address}
    calculate :name, :string, {Decrypt, field: :encrypted_name}
  end
end
