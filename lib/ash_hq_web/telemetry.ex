defmodule AshHqWeb.Telemetry do
  @moduledoc "Telemetry metrics registry/handler"
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),
      # Ash Metrics
      summary("ash.flow.stop.duration",
        unit: {:native, :millisecond},
        tags: [:flow_short_name]
      ),
      summary("ash.docs.read.stop.duration",
        tags: [:resource_short_name, :action],
        unit: {:native, :millisecond}
      ),
      summary("ash.docs.create.stop.duration",
        tags: [:resource_short_name, :action],
        unit: {:native, :millisecond}
      ),
      summary("ash.docs.update.stop.duration",
        tags: [:resource_short_name, :action],
        unit: {:native, :millisecond}
      ),
      summary("ash.docs.destroy.stop.duration",
        tags: [:resource_short_name, :action],
        unit: {:native, :millisecond}
      ),
      summary("ash.changeset.stop.duration",
        tags: [:resource_short_name, :action],
        unit: {:native, :millisecond}
      ),
      summary("ash.query.stop.duration",
        tags: [:resource_short_name, :action],
        unit: {:native, :millisecond}
      ),
      summary("ash.validation.stop.duration",
        tags: [:resource_short_name, :validation],
        unit: {:native, :millisecond}
      ),
      summary("ash.change.stop.duration",
        tags: [:resource_short_name, :change],
        unit: {:native, :millisecond}
      ),
      summary("ash.preparation.stop.duration",
        tags: [:resource_short_name, :preparation],
        unit: {:native, :millisecond}
      ),
      summary("ash.request_step.stop.duration",
        tags: [:name],
        unit: {:native, :millisecond}
      ),
      summary("ash.flow.custom_step.stop.duration",
        tags: [:flow_short_name, :name],
        unit: {:native, :millisecond}
      ),
      # Database Metrics
      summary("ash_hq.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      summary("ash_hq.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      summary("ash_hq.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      summary("ash_hq.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      summary("ash_hq.repo.query.idle_time",
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {AshHqWeb, :count_users, []}
    ]
  end
end
