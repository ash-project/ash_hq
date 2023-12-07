defmodule AshHq.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    flame_parent = FLAME.Parent.get()

    Appsignal.Phoenix.LiveView.attach()

    # topologies = Application.get_env(:libcluster, :topologies) || []

    children =
      [
        {FLAME.Pool,
         name: AshHq.ImporterPool, min: 0, max: 1, max_concurrency: 1, idle_shutdown_after: 30_000},
        !flame_parent && Supervisor.child_spec({Finch, name: AshHq.Finch}, id: AshHq.Finch),
        !flame_parent && Supervisor.child_spec({Finch, name: Swoosh.Finch}, id: Swoosh.Finch),
        AshHq.Vault,
        # Start the Ecto repository
        AshHq.Repo,
        AshHq.SqliteRepo,
        # Start the Telemetry supervisor
        AshHqWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: AshHq.PubSub},
        # Start the Endpoint (http/https)
        AshHqWeb.Endpoint,
        {AshHq.Docs.Library.Agent, nil},
        # !flame_parent && {Cluster.Supervisor, [topologies, [name: AshHq.ClusterSupervisor]]},
        {Haystack.Storage.ETS, storage: AshHq.Docs.Indexer.storage()},
        !flame_parent && {Cluster.Supervisor, [topologies, [name: AshHq.ClusterSupervisor]]},
        !flame_parent && AshHq.Docs.Indexer,
        !flame_parent && AshHq.Github.Monitor,
        !flame_parent && oban_worker(),
        !flame_parent && Application.get_env(:ash_hq, :discord_bot) && AshHq.Discord.Supervisor
      ]
      |> Enum.filter(& &1)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshHq.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshHqWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_worker do
    apis = Application.fetch_env!(:ash_hq, :ash_apis)
    config = Application.fetch_env!(:ash_hq, Oban)
    {Oban, AshOban.config(apis, config)}
  end
end
