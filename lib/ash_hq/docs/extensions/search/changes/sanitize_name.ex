defmodule AshHq.Docs.Extensions.Search.Changes.SanitizeName do
  @moduledoc """
  Writes the sanitized (url-safe) name of a record
  """

  use Ash.Resource.Change

  def change(changeset, opts, _) do
    use_path_for_name? = !!opts[:use_path_for_name?]
    source = opts[:source]
    destination = opts[:destination]

    if use_path_for_name? do
      if Ash.Changeset.changing_attribute?(changeset, :path) ||
           Ash.Changeset.changing_attribute?(changeset, source) do
        path = List.wrap(Ash.Changeset.get_attribute(changeset, :path))
        name = Ash.Changeset.get_attribute(changeset, source)

        value = Enum.map_join(path ++ [name], "/", &sanitize/1)

        Ash.Changeset.change_attribute(changeset, destination, value)
      else
        changeset
      end
    else
      if Ash.Changeset.changing_attribute?(changeset, source) do
        value =
          changeset
          |> Ash.Changeset.get_attribute(source)
          |> sanitize()

        Ash.Changeset.change_attribute(changeset, destination, value)
      else
        changeset
      end
    end
  end

  defp sanitize(nil) do
    nil
  end

  defp sanitize(value) do
    String.downcase(String.replace(value, ~r/[^A-Za-z0-9_]/, "-"))
  end
end
