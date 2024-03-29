defmodule AshHq.Docs.Guide.Changes.SetRoute do
  @moduledoc """
  Sets the route of a guide.
  """
  use Ash.Resource.Change

  def change(changeset, _, _) do
    if !Ash.Changeset.get_attribute(changeset, :route) &&
         (Ash.Changeset.changing_attribute?(changeset, :name) ||
            Ash.Changeset.changing_attribute?(changeset, :category)) do
      category = Ash.Changeset.get_attribute(changeset, :category)
      name = Ash.Changeset.get_attribute(changeset, :name)
      Ash.Changeset.change_attribute(changeset, :route, to_path(category) <> "/" <> to_path(name))
    else
      changeset
    end
  end

  defp to_path(string) do
    string
    |> String.split(~r/\s/, trim: true)
    |> Enum.join("-")
    |> String.downcase()
  end
end
