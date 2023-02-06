defmodule AshHq.Docs.Importer do
  @moduledoc """
  Builds the documentation into term files in the `priv/docs` directory.
  """

  use GenServer

  alias AshHq.Docs.LibraryVersion
  require Logger
  require Ash.Query

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    import_periodically()
    {:ok, %{}}
  end

  defp import_periodically do
    __MODULE__.import()
    Process.send_after(self(), :import, :timer.minutes(30))
  end

  def handle_info(:import, state) do
    import_periodically()
    {:noreply, state}
  end

  def reimport_guides do
    AshHq.Docs.Guide
    |> AshHq.Docs.read!()
    |> Enum.each(fn guide ->
      guide
      |> Ash.Changeset.for_update(:update)
      |> Map.update!(:attributes, &Map.put(&1, :text, guide.text))
      |> AshHq.Docs.update!()
    end)
  end

  def reimport_dsls do
    AshHq.Docs.Dsl
    |> AshHq.Docs.read!()
    |> Enum.each(fn dsl ->
      dsl
      |> Ash.Changeset.for_update(:update)
      |> Map.update!(:attributes, &Map.put(&1, :doc, dsl.doc))
      |> AshHq.Docs.update!()
    end)
  end

  def reimport_docs(library, opts \\ []) do
    library =
      AshHq.Docs.Library
      |> Ash.Query.filter(name == ^library)
      |> AshHq.Docs.read_one!(load: :latest_version)

    version = opts[:version] || library.latest_version

    import_version(
      library,
      library.name,
      library.repo_org,
      library.mix_project,
      path_var(),
      version,
      opts[:github_sha]
    )
  end

  # sobelow_skip ["Misc.BinToTerm", "Traversal.FileModule"]
  def import(opts \\ []) do
    only = opts[:only] || nil

    query =
      if only do
        AshHq.Docs.Library |> Ash.Query.filter(name in ^List.wrap(only))
      else
        AshHq.Docs.Library
      end

    path_var = path_var()

    for %{name: name, latest_version: latest_version, mix_project: mix_project} = library <-
          AshHq.Docs.Library.read!(load: :latest_version, query: query) do
      latest_version =
        if latest_version do
          Version.parse!(latest_version)
        end

      versions =
        Finch.build(:get, "https://hex.pm/api/packages/#{name}")
        |> Finch.request(AshHq.Finch)
        |> case do
          {:ok, response} ->
            Jason.decode!(response.body)

          {:error, error} ->
            raise "Something went wrong #{inspect(error)}"
        end
        |> Map.get("releases", [])
        |> Enum.map(&Map.get(&1, "version"))
        |> filter_by_version(latest_version)
        |> Enum.reverse()

      already_defined_versions =
        AshHq.Docs.LibraryVersion.defined_for!(
          library.id,
          versions
        )

      versions
      |> Enum.reject(fn version ->
        Enum.find(already_defined_versions, &(&1.version == version))
      end)
      |> Enum.each(fn version ->
        import_version(library, name, library.repo_org, mix_project, path_var, version)
      end)
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

    if result do
      AshHq.Repo.transaction(fn ->
        Logger.info("Starting import of #{name}: #{version}")

        id =
          case LibraryVersion.by_version(library.id, version) do
            {:ok, version} ->
              LibraryVersion.destroy!(version)
              version.id

            _ ->
              Ash.UUID.generate()
          end

        LibraryVersion.build!(
          library.id,
          version,
          %{
            timeout: :infinity,
            id: id,
            extensions: result[:extensions],
            doc: result[:doc],
            guides: result[:guides],
            modules: result[:modules],
            mix_tasks: result[:mix_tasks]
          }
        )
      end)
    end
  end

  defp filter_by_version(versions, latest_version) do
    if latest_version do
      Enum.take_while(versions, fn version ->
        Version.match?(Version.parse!(version), "> #{latest_version}")
      end)
    else
      Enum.take(versions, 1)
    end
  end
end
