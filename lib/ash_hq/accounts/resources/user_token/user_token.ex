defmodule AshHq.Accounts.UserToken do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: [AshHq.Accounts.EmailNotifier]

  alias AshHq.Accounts.UserToken.Changes, warn: false
  alias AshHq.Accounts.Preparations, warn: false

  postgres do
    table "user_tokens"
    repo AshHq.Repo

    references do
      reference :user, on_delete: :delete, on_update: :update
    end
  end

  identities do
    identity :token_context, [:context, :token]
  end

  actions do
    defaults [:read]

    read :verify_email_token do
      argument :token, :url_encoded_binary, allow_nil?: false
      argument :context, :string, allow_nil?: false
      prepare Preparations.SetHashedToken
      prepare Preparations.DetermineDaysForToken

      filter expr(
               token == ^context(:hashed_token) and context == ^arg(:context) and
                 created_at > ago(^context(:days_for_token), :day)
             )
    end

    create :build_session_token do
      primary? true

      argument :user, :map

      change manage_relationship(:user, type: :replace)
      change set_attribute(:context, "session")
      change Changes.BuildSessionToken
    end

    create :build_email_token do
      accept [:sent_to, :context]

      argument :user, :map

      change manage_relationship(:user, type: :replace)
      change Changes.BuildHashedToken
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :token, :binary
    attribute :context, :string
    attribute :sent_to, :string

    create_timestamp :created_at
  end

  relationships do
    belongs_to :user, AshHq.Accounts.User
  end
end
