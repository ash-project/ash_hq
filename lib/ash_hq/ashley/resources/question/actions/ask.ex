defmodule AshHq.Ashley.Question.Actions.Ask do
  use Ash.Resource.ManualCreate

  require Logger

  @system_message_limit 4000

  @static_context """
  You are an assistant for answering questions about the Ash Framework for the programming language Elixir. Your knowledge base is the actual documentation from Ash and your job is to format that documentation into answers that help the user solve their challenge. All answers should be based on the documentation provided only and shouldn’t include other information (other than what you use to format the answers more helpfully). If you don’t know the answer, do not make things up, and instead say, “Sorry, I’m not sure about that.”

  Use the following context from our documentation for your answer. Depending on the question you may simply pull excerpts or reformat the answer to be more helpful for the user. You may also offer new Elixir code that uses the documentation provided.

  Example Resource:
  defmodule Post do
    use Ash.Resource

    attributes do
      uuid_primary_key :id
      attribute :text, :string, allow_nil?: false
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
        topK: 4,
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
            matches
            |> Enum.sort_by(&String.length(&1["metadata"]["text"]))
            |> Enum.map_join("\n", & &1["metadata"]["text"])

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

        #{site_sources(sources)}
        """

        AshHq.Ashley.Question.create(conversation_id, actor.id, question, answer, true,
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
          authorize?: false
        )
    end
  end

  defp site_sources([]), do: ""

  defp site_sources(sources) do
    source_links =
      sources
      |> Enum.map(& &1["metadata"]["link"])
      |> Enum.filter(& &1)
      |> Enum.map_join("\n", fn link ->
        link = String.trim_leading(link, "https://ash-hq.org/")

        "<li><a href=\"#{AshHqWeb.Endpoint.config(:host)}/#{link}\">#{link}</a></li>"
      end)

    "Sources:\n<ul>#{source_links}</ul>"
  end
end
