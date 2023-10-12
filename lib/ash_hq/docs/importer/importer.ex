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
    send(self(), :import)
    {:ok, %{}}
  end

  def handle_info(:import, state) do
    __MODULE__.import()
    Process.send_after(self(), :import, :timer.minutes(30))
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

    version = opts[:version] || library.latest_version || latest_version(library.name)

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

      hex_info =
        Finch.build(:get, "https://hex.pm/api/packages/#{name}")
        |> Finch.request(AshHq.Finch)
        |> case do
          {:ok, response} ->
            Jason.decode!(response.body)

          {:error, error} ->
            raise "Something went wrong #{inspect(error)}"
        end

      retired_versions =
        hex_info
        |> Map.get("retirements", %{})
        |> Map.keys()

      versions =
        hex_info
        |> Map.get("releases", [])
        |> Enum.map(&Map.get(&1, "version"))
        |> Enum.reject(&(&1 in retired_versions))
        |> filter_by_version(latest_version)
        |> Enum.reverse()

      already_defined_versions =
        AshHq.Docs.LibraryVersion.defined_for!(
          library.id,
          versions
        )

      versions
      |> Enum.reject(fn version ->
        Enum.find(already_defined_versions, &(&1.version == version)) ||
          version in library.skip_versions
      end)
      |> Enum.each(fn version ->
        try do
          import_version(library, name, library.repo_org, mix_project, path_var, version)
        rescue
          e ->
            Logger.error(
              "Failed to import version #{name} #{version} #{Exception.format(:error, e, __STACKTRACE__)}"
            )

            e
        catch
          e ->
            Logger.error(
              "Failed to import version #{name} #{version} #{Exception.format(:error, e, __STACKTRACE__)}"
            )
        end
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

  defp latest_version(name) do
    hex_info =
      Finch.build(:get, "https://hex.pm/api/packages/#{name}")
      |> Finch.request(AshHq.Finch)
      |> case do
        {:ok, response} ->
          Jason.decode!(response.body)

        {:error, error} ->
          raise "Something went wrong #{inspect(error)}"
      end

    retired_versions =
      hex_info
      |> Map.get("retirements", %{})
      |> Map.keys()

    hex_info
    |> Map.get("releases", [])
    |> Enum.map(&Map.get(&1, "version"))
    |> Enum.reject(&(&1 in retired_versions))
    |> Enum.at(0)
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
      Logger.info("Starting import of #{name}: #{version}")

      library_version =
        LibraryVersion.build!(
          library.id,
          version,
          %{
            timeout: :infinity,
            extensions: result[:extensions],
            doc: result[:doc],
            guides: result[:guides],
            modules: result[:modules],
            mix_tasks: result[:mix_tasks]
          }
        )

      LibraryVersion
      |> Ash.Query.for_read(:read)
      |> Ash.Query.filter(id != ^library_version.id)
      |> Ash.Query.filter(library_id == ^library.id)
      |> Ash.Query.data_layer_query()
      |> case do
        {:ok, query} ->
          AshHq.Repo.delete_all(query)

        other ->
          raise "bad match #{inspect(other)}"
      end
    end
  end

  defp filter_by_version(versions, _latest_version) do
    Enum.take(versions, 1)
  end
end
