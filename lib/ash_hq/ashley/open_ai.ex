defmodule AshHq.Ashley.OpenAi do
  @moduledoc false
  @open_ai_embed_model "text-embedding-ada-002"
  @open_ai_chat_model "gpt-3.5-turbo"
  @message_token_limit 3500

  @dialyzer {:nowarn_function, {:complete, 4}}

  def create_embeddings(embeddings) do
    OpenAI.Embeddings.create(@open_ai_embed_model, embeddings, user: "ash-hq-importer")
  end

  def complete(system_message, system_message_tokens, messages, user_email) do
    OpenAI.Chat.create_completion(
      @open_ai_chat_model,
      [
        %{role: :system, content: system_message}
        | fit_to_tokens(messages, @message_token_limit - system_message_tokens)
      ],
      user: user_email
    )
  end

  defp fit_to_tokens(messages, remaining) do
    messages
    |> Enum.reverse()
    |> Enum.reduce_while({remaining, []}, fn message, {remaining, stack} ->
      tokens = tokens(message)

      if tokens <= remaining do
        {:cont, {remaining - tokens, [message | stack]}}
      else
        {:halt, {remaining, stack}}
      end
    end)
    |> elem(1)
  end

  def tokens(%{content: message}) do
    tokens(message)
  end

  def tokens(message) do
    # Can't link to my python, so I'm just making a conservative estimate
    # a token is ~4 chars
    # Tiktoken.CL100K.encode_ordinary(message)

    message
    |> String.length()
    |> div(3)
    |> Kernel.+(4)
  end
end
