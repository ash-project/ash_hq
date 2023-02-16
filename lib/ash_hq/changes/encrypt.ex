defmodule AshHq.Changes.Encrypt do
  @moduledoc "Encrypt attributes that are being changed before submitting the action"
  use Ash.Resource.Change

  def change(changeset, opts, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      Enum.reduce(opts[:fields], changeset, fn field, changeset ->
        case Ash.Changeset.fetch_change(changeset, field) do
          {:ok, value} when is_binary(value) ->
            new_value =
              value
              |> AshHq.Vault.encrypt!()
              |> Base.encode64()

            Ash.Changeset.force_change_attribute(changeset, field, new_value)

          _ ->
            changeset
        end
      end)
    end)
  end
end
