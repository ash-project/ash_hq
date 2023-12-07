defmodule AshHq.Docs.Library.Preparations.FilterPendingImport do
  use Ash.Resource.Preparation

  def prepare(query, _opts, _context) do
    query
    |> Ash.Query.ensure_selected([:name])
    |> Ash.Query.load(:latest_version)
    |> Ash.Query.after_action(fn query, results ->
      pending_import =
        results
        |> query.api.load!(:latest_version)
        |> Enum.flat_map(fn result ->
          hex_info =
            Finch.build(:get, "https://hex.pm/api/packages/#{result.name}")
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

          latest_version =
            hex_info
            |> Map.get("releases", [])
            |> Stream.map(&Map.get(&1, "version"))
            |> Stream.reject(&(&1 in retired_versions))
            |> Enum.at(0)

          if is_nil(result.latest_version) ||
               Version.compare(latest_version, result.latest_version) == :gt do
            [Ash.Resource.set_metadata(result, %{version: latest_version})]
          else
            []
          end
        end)

      {:ok, pending_import}
    end)
  end
end
