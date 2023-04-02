defmodule AshHq.Ashley.Question.Changes.ValidateLimit do
  @moduledoc false
  use Ash.Resource.Change

  def change(changeset, opts, %{actor: actor}) do
    Ash.Changeset.before_action(
      changeset,
      fn changeset ->
        count =
          AshHq.Ashley.Question
          |> Ash.Query.for_read(:questions_in_time_frame, %{}, actor: actor)
          |> AshHq.Ashley.count!()

        if count >= opts[:question_limit] do
          Ash.Changeset.add_error(changeset, message: "Question Quota Reached", field: :question)
        else
          changeset
        end
      end,
      prepend?: true
    )
  end
end
