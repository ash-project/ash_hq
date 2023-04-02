defmodule AshHq.Ashley.Question do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshHq.Docs.Extensions.RenderMarkdown]

  @time_frame_hours 24
  @question_limit 10

  actions do
    defaults [:read, :destroy]

    read :history do
      argument :user, :uuid do
        allow_nil? false
      end

      argument :conversation, :uuid do
        allow_nil? false
      end

      prepare build(sort: [inserted_at: :asc])

      filter expr(user_id == ^arg(:user) and conversation_id == ^arg(:conversation))
    end

    create :ask do
      transaction? false
      accept [:question, :conversation_id]
      allow_nil_input [:conversation_id]

      argument :conversation_name, :string

      change fn changeset, %{actor: actor} ->
        Ash.Changeset.before_action(changeset, fn changeset ->
          if Ash.Changeset.get_attribute(changeset, :conversation_id) do
            changeset
          else
            conversation =
              AshHq.Ashley.Conversation.create!(
                changeset.arguments[:conversation_name] || "New Conversation",
                actor: actor
              )

            Ash.Changeset.force_change_attribute(changeset, :conversation_id, conversation.id)
          end
        end)
      end

      change fn changeset, _ ->
        Ash.Changeset.timeout(changeset, :timer.minutes(3))
      end

      change {AshHq.Ashley.Question.Changes.ValidateLimit, limit: @question_limit}

      manual AshHq.Ashley.Question.Actions.Ask
    end

    create :create do
      accept [:conversation_id, :question, :answer, :success, :user_id, :sources]
    end

    read :questions_in_time_frame do
      filter expr(
               user_id == ^actor(:id) and inserted_at >= ago(@time_frame_hours, :hour) and success
             )
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :question, :string do
      allow_nil? false
    end

    attribute :answer, :string do
      allow_nil? false
    end

    attribute :sources, {:array, AshHq.Ashley.Question.Types.Source} do
      allow_nil? false
      default []
    end

    attribute :answer_html, :string do
      allow_nil? false
    end

    attribute :success, :boolean do
      allow_nil? false
    end

    timestamps()
  end

  render_markdown do
    render_attributes answer: :answer_html
  end

  relationships do
    belongs_to :user, AshHq.Accounts.User do
      allow_nil? false
      api AshHq.Accounts
      attribute_writable? true
    end

    belongs_to :conversation, AshHq.Ashley.Conversation do
      allow_nil? false
      attribute_writable? true
    end
  end

  policies do
    policy always() do
      authorize_if actor_present()
    end

    policy action_type(:read) do
      authorize_if action(:history)
      authorize_if accessing_from(AshHq.Ashley.Conversation, :questions)
      authorize_if expr(user_id == ^actor(:id))
    end

    policy action(:history) do
      authorize_if expr(^actor(:id) == ^arg(:user))
    end

    policy action(:create) do
      forbid_if always()
    end
  end

  postgres do
    table "questions"
    repo AshHq.Repo

    migration_defaults sources: "[]"

    references do
      reference :conversation, on_delete: :delete
    end
  end

  code_interface do
    define_for AshHq.Ashley

    define :questions_in_time_frame
    define :ask, args: [:question]
    define :create, args: [:conversation_id, :user_id, :question, :answer, :success, :sources]
    define :history, args: [:user, :conversation]
  end
end
