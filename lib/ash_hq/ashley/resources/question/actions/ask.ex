defmodule AshHq.Ashley.Question.Actions.Ask do
  @moduledoc false
  use Ash.Resource.ManualCreate

  require Logger

  @dialyzer {:nowarn_function, {:create, 3}}

  @system_message_limit 4000

  @static_context """
  You are an assistant for helping users find relevant documentation about the Ash Framework for the programming language Elixir.
  Above all else, you should provide links to relevant documentation. If you don’t know the answer, do not make things up, and instead say, “Sorry, I’m not sure about that.”

  Use the following context from our documentation for your answer. All answers should be based on the documentation provided only.

  Example Resource:
  defmodule Post do
    use Ash.Resource

    actions do
      defaults [:read, :update, :destroy]

      create :create do
        accept [:text]
        change {Slugify, field: text}
      end
    end

    attributes do
      uuid_primary_key :id
      attribute :text, :string, allow_nil?: false
      attribute :slug, :string, allow_nil?: false
    end

    relationships do
      belongs_to :author, User
    end
  end
  """

  @system_message_tokens AshHq.Ashley.OpenAi.tokens(@static_context)

  def create(changeset, _, %{actor: actor}) do
    question = Ash.Changeset.get_attribute(changeset, :question)

    {:ok, %{"data" => [%{"embedding" => vector} | _]}} =
      AshHq.Ashley.OpenAi.create_embeddings([question])

    {prompt, sources, system_message, system_message_tokens} =
      AshHq.Ashley.Pinecone.client()
      |> Pinecone.Vector.query(%{
        vector: vector,
        topK: 10,
        includeMetadata: true,
        includeValues: true
      })
      |> case do
        {:ok,
         %{
           "matches" => []
         }} ->
          {
            %{
              role: :user,
              content: question
            },
            [],
            @static_context,
            @system_message_tokens
          }

        {:ok,
         %{
           "matches" => matches
         }} ->
          # This is inefficient
          context =
            Enum.map_join(
              matches,
              "\n",
              &"""
              <a href="https://ash-hq.org/#{&1["metadata"]["link"]}>#{&1["metadata"]["name"]}</a>:
              #{&1["metadata"]["text"]}
              """
            )

          system_message =
            """
            #{@static_context}

            #{context}
            """
            |> String.slice(0..@system_message_limit)

          {
            %{
              role: :user,
              content: question
            },
            matches,
            system_message,
            AshHq.Ashley.OpenAi.tokens(system_message)
          }
      end

    conversation_id = Ash.Changeset.get_attribute(changeset, :conversation_id)

    conversation_messages =
      AshHq.Ashley.Question.history!(
        actor.id,
        conversation_id,
        query: Ash.Query.select(AshHq.Ashley.Question, [:question, :answer]),
        actor: actor
      )
      |> Enum.flat_map(fn message ->
        [
          %{
            role: :user,
            content: message.question
          },
          %{
            role: :assistant,
            content: message.answer
          }
        ]
      end)

    case AshHq.Ashley.OpenAi.complete(
           system_message,
           system_message_tokens,
           conversation_messages ++ [prompt],
           actor.email
         ) do
      {:ok,
       %{
         "choices" => [
           %{
             "message" => %{
               "content" => answer
             }
           }
           | _
         ]
       }} ->
        answer = """
        #{answer}
        """

        AshHq.Ashley.Question.create(
          conversation_id,
          actor.id,
          question,
          answer,
          true,
          sources(sources),
          authorize?: false
        )

      {:error, error} ->
        Logger.error("""
        Something went wrong creating a completion

        #{Exception.message(error)}
        """)

        AshHq.Ashley.Question.create(
          conversation_id,
          actor.id,
          question,
          "Something went wrong",
          false,
          sources(sources),
          authorize?: false
        )
    end
  end

  defp sources([]), do: ""

  defp sources(sources) do
    sources
    |> Enum.map(
      &%{
        link: &1["metadata"]["link"],
        name: &1["metadata"]["name"]
      }
    )
    |> Enum.filter(& &1)
  end
end
