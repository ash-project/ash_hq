defmodule AshHq.Github.Contributor.Actions.Import do
  @moduledoc "Polls github for new contributors every 6 hours"
  use Ash.Resource.Actions.Implementation
  require Logger

  def run(_input, _, _) do
    AshHq.Docs.Library
    |> Ash.stream!()
    |> Stream.flat_map(fn library ->
      opts = []

      opts =
        if api_key = Application.get_env(:ash_hq, :github)[:api_key] do
          Keyword.put(opts, :headers, [{"Authorization", "token #{api_key}"}])
        else
          opts
        end

      "https://api.github.com/repos/#{library.repo_org}/#{library.name}/contributors"
      |> Req.get!(opts)
      |> case do
        %{status: 200, body: body} ->
          Stream.map(body, &Map.take(&1, ["id", "avatar_url", "html_url", "login"]))

        resp ->
          Logger.error("Invalid response from GH: #{inspect(resp)}")
          []
      end
    end)
    |> Stream.with_index()
    |> Stream.map(fn {contributor, index} ->
      Map.put(contributor, "order", index)
    end)
    |> Stream.uniq_by(&Map.get(&1, "id"))
    |> Ash.bulk_create(AshHq.Github.Contributor, :create,
      upsert?: true,
      upsert_fields: [:order, :login, :avatar_url, :html_url],
      return_errors?: true,
      stop_on_error?: true
    )

    {:ok, :ok}
  rescue
    e ->
      Logger.error("Error while getting contributors: #{inspect(e)}")
      {:ok, :error}
  catch
    e ->
      Logger.error("Error while getting contributors: #{inspect(e)}")
      {:ok, :error}
  end
end
