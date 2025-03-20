defmodule AshHq.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :erlang.system_flag(:backtrace_depth, 1000)
    Appsignal.Phoenix.LiveView.attach()

    # topologies = Application.get_env(:libcluster, :topologies) || []

    children =
      [
        Supervisor.child_spec({Finch, name: AshHq.Finch}, id: AshHq.Finch),
        Supervisor.child_spec({Finch, name: Swoosh.Finch}, id: Swoosh.Finch),
        AshHq.Vault,
        # Start the Ecto repository
        AshHq.Repo,
        # Start the Telemetry supervisor
        AshHqWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: AshHq.PubSub},
        # Start the Endpoint (http/https)
        AshHqWeb.Endpoint,
        {AshHq.Docs.Library.Agent, nil},
        # {Cluster.Supervisor, [topologies, [name: AshHq.ClusterSupervisor]]},
        # {Haystack.Storage.ETS, storage: AshHq.Docs.Indexer.storage()},
        # AshHq.Docs.Indexer,
        oban_worker(),
        Application.get_env(:ash_hq, :discord_bot) && AshHq.Discord.Supervisor
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
    :logger.add_handler(:my_sentry_handler, Sentry.LoggerHandler, %{
      config: %{metadata: [:file, :line]}
    })

    AshHqWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_worker do
    domains = Application.fetch_env!(:ash_hq, :ash_domains)
    config = Application.fetch_env!(:ash_hq, Oban)
    {Oban, AshOban.config(domains, config)}
  end
end
