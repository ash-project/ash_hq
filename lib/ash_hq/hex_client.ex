defmodule AshHq.HexClient do
  @moduledoc """
  Client for fetching package information from Hex.pm with caching support.
  """
  use GenServer
  require Logger

  @cache_duration_hours 3
  @hex_api_url "https://hex.pm/api/packages/phx_new"

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Fetches the latest Phoenix installer version, including release candidates.
  Returns the version string or nil on failure.
  """
  def get_latest_phoenix_version do
    GenServer.call(__MODULE__, :get_latest_phoenix_version)
  catch
    :exit, _ -> nil
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{cache: %{}, last_fetch: nil}}
  end

  @impl true
  def handle_call(:get_latest_phoenix_version, _from, state) do
    case maybe_fetch_version(state) do
      {:ok, version, new_state} ->
        {:reply, version, new_state}

      {:error, _reason} ->
        # Return cached version if available, otherwise nil
        cached_version = get_in(state, [:cache, :phoenix_version])
        {:reply, cached_version, state}
    end
  end

  # Private Functions

  defp maybe_fetch_version(state) do
    now = DateTime.utc_now()

    cache_expired? =
      is_nil(state.last_fetch) or
        DateTime.diff(now, state.last_fetch, :hour) >= @cache_duration_hours

    cached_version = get_in(state, [:cache, :phoenix_version])

    if cache_expired? or is_nil(cached_version) do
      fetch_and_cache_version(state, now)
    else
      {:ok, cached_version, state}
    end
  end

  defp fetch_and_cache_version(state, now) do
    with {:ok, response} <- fetch_hex_package_info(),
         {:ok, version} <- extract_latest_version(response) do
      new_state =
        state
        |> put_in([:cache, :phoenix_version], version)
        |> Map.put(:last_fetch, now)

      Logger.info("Fetched latest Phoenix version: #{version}")
      {:ok, version, new_state}
    else
      {:error, reason} = error ->
        Logger.error("Failed to fetch Phoenix version: #{inspect(reason)}")
        error
    end
  end

  defp fetch_hex_package_info do
    case Req.get(@hex_api_url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end

  defp extract_latest_version(%{"releases" => releases}) when is_list(releases) do
    # Sort releases by version, including pre-releases
    # Hex API returns them in reverse chronological order, but we'll sort to be sure
    latest =
      releases
      |> Enum.map(& &1["version"])
      |> Enum.filter(&is_binary/1)
      |> Enum.sort(&version_compare/2)
      |> List.last()

    if latest do
      {:ok, latest}
    else
      {:error, :no_versions_found}
    end
  end

  defp extract_latest_version(_), do: {:error, :invalid_response_format}

  # Compare versions, putting release candidates after stable versions
  # but still considering them as valid latest versions
  defp version_compare(v1, v2) do
    case Version.compare(v1, v2) do
      :lt -> true
      :gt -> false
      :eq -> false
    end
  rescue
    # If Version.compare fails (shouldn't happen with valid Hex versions),
    # fall back to string comparison
    _ -> v1 <= v2
  end
end
