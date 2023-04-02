defmodule AshHq.Ashley.Conversation do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  @conversation_limit 5

  def conversation_limit, do: @conversation_limit

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name]
    end

    update :update do
      accept [:name]
    end

    update :ask do
      transaction? false

      argument :question, :string do
        allow_nil? false
      end

      manual fn changeset, _ ->
        changeset.data
        |> AshHq.Ashley.load!(:over_limit)
        |> Map.get(:over_limit)
        |> if do
          Ash.Changeset.add_error(%{changeset | data: %{changeset.data | over_limit: true}},
            message: "Conversation limit reached",
            field: :question
          )
        else
          AshHq.Ashley.Question.ask!(changeset.argument.question, changeset.data.id)
        end
      end
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
  end

  relationships do
    has_many :questions, AshHq.Ashley.Question

    belongs_to :user, AshHq.Accounts.User do
      api AshHq.Accounts
      allow_nil? false
    end
  end

  policies do
    policy action_type(:create) do
      authorize_if relating_to_actor(:user)
    end

    policy action_type([:read, :update, :destroy]) do
      authorize_if relates_to_actor_via(:user)
    end
  end

  postgres do
    table "conversations"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Ashley
    define :create, args: [:name]
    define :read
    define :destroy
  end

  changes do
    change relate_actor(:user), on: [:create]
  end

  aggregates do
    count :question_count, [:questions] do
      filter expr(success)
    end
  end

  calculations do
    calculate :over_limit, :boolean, expr(question_count > ^@conversation_limit)
  end
end
