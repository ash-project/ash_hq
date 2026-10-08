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

      "https://api.github.com/repos/#{library.repo_org}/#{library.name}/contributors?per_page=100"
      |> contributors(opts)
      |> Stream.map(&Map.take(&1, ["id", "avatar_url", "html_url", "login"]))
    end)
    |> Stream.with_index()
    |> Stream.map(fn {contributor, index} ->
      Map.put(contributor, "order", index)
    end)
    |> Stream.uniq_by(&Map.get(&1, "id"))
    |> Stream.reject(&String.starts_with?(Map.get(&1, "login"), "dependabot"))
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

  # GitHub returns contributors a page at a time, linking to the next page in the `link` header
  defp contributors(nil, _opts), do: []

  defp contributors(url, opts) do
    case Req.get!(url, opts) do
      %{status: 200, body: body} = resp ->
        body ++ contributors(next_page(resp), opts)

      resp ->
        Logger.error("Invalid response from GH: #{inspect(resp)}")
        []
    end
  end

  defp next_page(resp) do
    resp
    |> Req.Response.get_header("link")
    |> Enum.find_value(fn link ->
      case Regex.run(~r/<([^>]+)>;\s*rel="next"/, link) do
        [_, url] -> url
        _ -> nil
      end
    end)
  end
end
