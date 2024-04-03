defmodule AshHq.MailingList.Email do
  @moduledoc false

  use Ash.Resource,
    domain: AshHq.MailingList,
    data_layer: AshPostgres.DataLayer,
    notifiers: AshHq.MailingList.EmailNotifier

  actions do
    default_accept :*
    defaults [:create, :read]
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      public? true
      allow_nil? false
    end

    timestamps()
  end

  postgres do
    repo AshHq.Repo
    table "emails"
  end

  code_interface do
    define :all, action: :read
  end

  resource do
    description "An email for the mailing list"
  end

  identities do
    identity :unique_email, [:email]
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+$/), message: "must have the @ sign and no spaces"
  end
end
