defmodule AshHq.Docs.Importer do
  @moduledoc """
  Builds the documentation into term files in the `priv/docs` directory.
  """

  alias AshHq.Docs.LibraryVersion
  require Logger

  def import() do
    for %{name: name, latest_version: latest_version} = library <-
          AshHq.Docs.Library.read!(load: :latest_version) do
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

      # TODO: reenable this
      # versions
      # |> Enum.reject(fn version ->
      #   Enum.find(already_defined_versions, &(&1.version == version))
      # end)
      []
      |> Enum.concat(Enum.map(library.track_branches, &{&1, true}))
      |> Enum.each(fn version ->
        {version, branch?} =
          case version do
            {version, true} -> {version, true}
            _ -> {version, false}
          end

        file = Path.expand("./#{Ash.UUID.generate()}.json")

        {_, 0} =
          System.cmd("elixir", [
            "./build_docs/build_dsl_docs.exs",
            name,
            version,
            file,
            to_string(branch?)
          ])

        output = File.read!(file)
        result = :erlang.binary_to_term(Base.decode64!(String.trim(output)))
        File.rm!(file)

        if result do
          LibraryVersion.build!(library.id, version, result, %{
            doc: result[:doc],
            guides: result[:guides],
            modules: result[:modules]
          })
        end
      end)
    end

    for version <- LibraryVersion.unprocessed!() do
      try do
        LibraryVersion.process!(version)
      rescue
        e ->
          Logger.error(
            "Exception while importing: #{version.id}\n#{Exception.format(:error, e, __STACKTRACE__)}"
          )

          :ok
      end
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
