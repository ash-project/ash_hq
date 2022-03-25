defmodule AshHq.Docs.Changes.AddArgToRelationship do
  use Ash.Resource.Change

  def change(changeset, opts, _) do
    arg = opts[:arg]
    rel = opts[:rel]

    arg_value = Ash.Changeset.get_argument(changeset, arg)

    relationship_value = Ash.Changeset.get_argument(changeset, rel)

    new_value =
      cond do
        is_list(relationship_value) ->
          Enum.map(relationship_value, fn val ->
            Map.put(val, arg, arg_value)
          end)

        is_map(relationship_value) ->
          Map.put(relationship_value, arg, arg_value)

        true ->
          relationship_value
      end

    Ash.Changeset.set_argument(changeset, rel, new_value)
  end
end
