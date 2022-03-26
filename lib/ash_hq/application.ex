defmodule AshHq.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: AshHq.Finch},
      # Start the Ecto repository
      AshHq.Repo,
      # Start the Telemetry supervisor
      AshHqWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AshHq.PubSub},
      # Start the Endpoint (http/https)
      AshHqWeb.Endpoint
      # Start a worker by calling: AshHq.Worker.start_link(arg)
      # {AshHq.Worker, arg}
    ]

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
