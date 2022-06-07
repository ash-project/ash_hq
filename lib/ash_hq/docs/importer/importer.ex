defmodule AshHq.Docs.Importer do
  @moduledoc """
  Builds the documentation into term files in the `priv/docs` directory.
  """

  alias AshHq.Docs.LibraryVersion
  require Logger
  require Ash.Query

  def import(opts \\ []) do
    only = opts[:only] || nil
    only_branches? = opts[:only_branches?] || false

    query =
      if only do
        AshHq.Docs.Library |> Ash.Query.filter(name in ^List.wrap(only))
      else
        AshHq.Docs.Library
      end

    for %{name: name, latest_version: latest_version} = library <-
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

      if only_branches? do
        []
      else
        versions
        |> Enum.reject(fn version ->
          Enum.find(already_defined_versions, &(&1.version == version))
        end)
      end
      |> Enum.concat(Enum.map(library.track_branches, &{&1, true}))
      |> Enum.each(fn version ->
        {version, branch?} =
          case version do
            {version, true} -> {version, true}
            _ -> {version, false}
          end

        file = Path.expand("./#{Ash.UUID.generate()}.json")

        result =
          try do
            with_retry(fn ->
              {_, 0} =
                System.cmd("elixir", [
                  Path.join(:code.priv_dir(:ash_hq), "scripts/build_dsl_docs.exs"),
                  name,
                  version,
                  file,
                  to_string(branch?)
                ])

              output = File.read!(file)
              :erlang.binary_to_term(Base.decode64!(String.trim(output)))
            end)
          after
            File.rm_rf!(file)
          end

        if result do
          AshHq.Repo.transaction(fn ->
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
                modules: result[:modules]
              }
            )
          end)
        end
      end)
    end
  end

  defp with_retry(func, retries \\ 3) do
    func.()
  rescue
    e ->
      if retries == 1 do
        reraise e, __STACKTRACE__
      else
        with_retry(func, retries - 1)
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
