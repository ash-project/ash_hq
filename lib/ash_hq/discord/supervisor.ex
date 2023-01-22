defmodule AshHq.Discord.Supervisor do
  @moduledoc "Supervises the discord listener"
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [AshHq.Discord.Listener]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
