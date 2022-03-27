defmodule AshHq.Docs.Changes.AddArgToRelationship do
  use Ash.Resource.Change

  def change(changeset, opts, _) do
    arg = opts[:arg]
    rel = opts[:rel]
    attr = opts[:attr]
    generate = opts[:generate]

    {changeset, arg_value} =
      if attr do
        val = Ash.Changeset.get_attribute(changeset, attr)

        changeset =
          if is_nil(val) && generate do
            Ash.Changeset.force_change_attribute(changeset, attr, generate.())
          else
            changeset
          end

        {changeset, Ash.Changeset.get_attribute(changeset, attr)}
      else
        {changeset, Ash.Changeset.get_argument(changeset, arg)}
      end

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
