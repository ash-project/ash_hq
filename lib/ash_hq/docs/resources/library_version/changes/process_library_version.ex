defmodule AshHq.Docs.LibraryVersion.Changes.ProcessLibraryVersion do
  use Ash.Resource.Change

  require Logger

  alias AshHq.Docs
  alias AshHq.Docs.{Extension}

  def change(changeset, _, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      if changeset.data.processed do
        changeset
      else
        notifications = process(changeset.data, Ash.Changeset.get_attribute(changeset, :data))

        {Ash.Changeset.force_change_attribute(changeset, :processed, true),
         %{notifications: notifications}}
      end
    end)
  end

  defp process(library_version, data) do
    library_version = Docs.load!(library_version, :extensions)
    process_extensions(library_version, data["extensions"] || [])
  end

  defp process_extensions(library_version, extensions) do
    {extensions, notifications} =
      Enum.reduce(extensions, {[], []}, fn config, {extensions, notifications} ->
        case Extension.import(library_version.id, config,
               upsert?: true,
               upsert_identity: :unique_name_by_library_version,
               return_notifications?: true
             ) do
          {:ok, extension, new_notifications} ->
            {[extension | extensions], notifications ++ new_notifications}

          {:error, %{changeset: changeset} = error} ->
            Logger.error(
              "Error importing extension with #{inspect(changeset.params)} #{Exception.format(:error, error)}"
            )

            {extensions, notifications}
        end
      end)

    destroy_notifications =
      library_version.extensions
      |> Enum.reject(fn extension -> Enum.any?(extensions, &(&1.name == extension.name)) end)
      |> Enum.flat_map(&Extension.destroy!(&1, return_notifications?: true))

    notifications ++ destroy_notifications
  end
end
