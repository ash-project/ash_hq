defmodule AshHq.Docs.Library.Actions.Import do
  @moduledoc false
  use Ash.Resource.ManualUpdate
  require Ash.Query
  require Logger

  def update(changeset, _opts, _context) do
    import_version(
      changeset.data,
      changeset.data.name,
      changeset.data.repo_org,
      changeset.data.mix_project,
      path_var(),
      changeset.arguments.metadata.version
    )
    |> case do
      :ok ->
        {:ok, changeset.data}

      other ->
        other
    end
  end

  defp path_var do
    "PATH"
    |> System.get_env()
    |> String.split(":")
    |> Enum.reject(&String.starts_with?(&1, "/_build"))
    |> Enum.join(":")
  end

  # sobelow_skip ["Misc.BinToTerm", "Traversal.FileModule"]
  defp import_version(library, name, repo_org, mix_project, path_var, version, github_sha \\ nil) do
    file = Path.expand("./#{Ash.UUID.generate()}.json")

    args = [
      Path.join([:code.priv_dir(:ash_hq), "scripts", "build_dsl_docs.exs"]),
      name,
      version,
      file,
      mix_project || Macro.camelize(name) <> ".MixProject",
      repo_org
    ]

    args =
      if github_sha do
        args ++ [github_sha]
      else
        args
      end

    result =
      try do
        case System.cmd(
               "elixir",
               args,
               env: %{"PATH" => path_var}
             ) do
          {_, 0} ->
            :ok

          {output, error} ->
            raise """
            Error while importing #{name}: #{error}

            #{output}
            """
        end

        output = File.read!(file)
        :erlang.binary_to_term(Base.decode64!(String.trim(output)))
      after
        File.rm_rf!(file)
      end

    Logger.info("Starting import of #{name}: #{version}")

    if Ash.exists?(
         Ash.Query.for_read(AshHq.Docs.LibraryVersion, :read)
         |> Ash.Query.filter(library_id == ^library.id and version == ^version)
       ) do
      :ok
    else
      AshHq.Repo.transaction(
        fn ->
          library_version =
            AshHq.Docs.LibraryVersion.build!(
              library.id,
              version,
              %{
                extensions: result[:extensions],
                doc: result[:doc],
                guides: result[:guides],
                modules: result[:modules],
                mix_tasks: result[:mix_tasks]
              },
              timeout: :infinity
            )

          delete_except(library_version.id, library.id)
        end,
        timeout: :infinity
      )
      |> case do
        {:ok, _} -> :ok
        other -> other
      end
    end
  end

  defp delete_except(library_version_id, library_id) do
    AshHq.Docs.LibraryVersion
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id != ^library_version_id)
    |> Ash.Query.filter(library_id == ^library_id)
    |> Ash.Query.data_layer_query()
    |> case do
      {:ok, query} ->
        AshHq.Repo.delete_all(query)

      other ->
        raise "bad match #{inspect(other)}"
    end
  end
end
