defmodule AshHq.MailingList.Email do
  @moduledoc false

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    notifiers: AshHq.MailingList.EmailNotifier

  postgres do
    repo AshHq.Repo
    table "emails"
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
    end

    timestamps()
  end

  actions do
    defaults [:create, :read]
  end

  code_interface do
    define_for AshHq.MailingList

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
