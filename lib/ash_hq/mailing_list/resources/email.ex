defmodule AshHq.MailingList.Email do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: AshHq.MailingList.EmailNotifier

  resource do
    description "An email for the mailing list"
  end

  postgres do
    repo AshHq.Repo
    table "emails"
  end

  identities do
    identity :unique_email, [:email]
  end

  actions do
    defaults [:create, :read]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
    end

    timestamps()
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/), message: "must have the @ sign and no spaces"
  end
end
