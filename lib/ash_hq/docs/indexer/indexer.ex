defmodule AshHq.Docs.Indexer do
  use GenServer

  alias Elasticlunr.{Index, IndexManager, Pipeline}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_) do
    {:ok, %{}, {:continue, :index}}
  end

  def handle_continue(:index, state) do
    index =
      case IndexManager.get("docs") do
        {:ok, index} ->
          index
          IO.inspect("it was started")

        :not_running ->
          pipeline = Pipeline.new(Pipeline.default_runners())
          index = Index.new(pipeline: pipeline, store_documents: true)
          IO.inspect("started it")

          {:ok, _} = IndexManager.save(index)
          index
      end

    IO.inspect(index)

    {:noreply, state}
  end
end
