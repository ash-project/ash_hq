defmodule AshHq.Github.Monitor do
  @moduledoc "Polls github for new contributors every 6 hours"
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_) do
    {:ok, %{}, {:continue, :poll}}
  end

  def handle_continue(:poll, state) do
    {:noreply, poll(state)}
  end

  def handle_info(:poll, state) do
    {:noreply, poll(state)}
  end

  defp poll(state) do
    AshHq.Docs.Library
    |> AshHq.Docs.read!()
    |> Stream.flat_map(fn library ->
      :timer.sleep(1000)

      "https://api.github.com/repos/#{library.repo_org}/#{library.name}/contributors"
      |> Req.get!(headers: [{"Authorization", "token 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"}])
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
    |> AshHq.Github.bulk_create(AshHq.Github.Contributor, :create,
      upsert?: true,
      upsert_fields: [:order, :login, :avatar_url, :html_url],
      return_errors?: true,
      stop_on_error?: true
    )

    state
  rescue
    e ->
      Logger.error("Error while getting contributors: #{inspect(e)}")
      state
  catch
    e ->
      Logger.error("Error while getting contributors: #{inspect(e)}")
      state
  after
    Process.send_after(self(), :poll, :timer.hours(6))
  end
end
