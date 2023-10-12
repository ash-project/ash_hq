defmodule AshHq.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Appsignal.Phoenix.LiveView.attach()

    importer =
      if Application.get_env(:ash_hq, :periodic_imports) do
        [
          AshHq.Docs.Importer
        ]
      else
        []
      end

    discord_bot =
      if Application.get_env(:ash_hq, :discord_bot) do
        [AshHq.Discord.Supervisor]
      else
        []
      end

    topologies = Application.get_env(:libcluster, :topologies) || []

    children =
      [
        Supervisor.child_spec({Finch, name: AshHq.Finch}, id: AshHq.Finch),
        Supervisor.child_spec({Finch, name: Swoosh.Finch}, id: Swoosh.Finch),
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
        {Cluster.Supervisor, [topologies, [name: AshHq.ClusterSupervisor]]},
        {Haystack.Storage.ETS, storage: AshHq.Docs.Indexer.storage()},
        AshHq.Docs.Indexer,
        AshHq.Github.Monitor
        # Start a worker by calling: AshHq.Worker.start_link(arg)
        # {AshHq.Worker, arg}
      ] ++ importer ++ discord_bot

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
end
