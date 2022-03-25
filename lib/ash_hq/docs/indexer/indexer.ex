defmodule AshHq.Docs.Indexer do
  use GenServer

  alias Elasticlunr.{Index, IndexManager, Pipeline}

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(_) do
    {:ok, %{}, {:continue, :index}}
  end

  def handle_continue(:index, _state) do
    {index, reindex?} =
      case IndexManager.get("docs") do
        :not_running ->
          pipeline = Pipeline.new(Pipeline.default_runners())

          index =
            Index.new(
              pipeline: pipeline,
              store_documents: true,
              store_positions: true,
              name: "docs"
            )
            |> Index.add_field("name")
            |> Index.add_field("extension_type")
            |> Index.add_field("path")
            |> Index.add_field("doc")
            |> Index.add_field("library_version_id")
            |> Index.add_field("type")
            |> Index.add_field("extension_type")

          {:ok, _} = IndexManager.save(index)
          {index, true}

        index ->
          {index, false}
      end

    if reindex? do
      {:noreply, %{index: index}, {:continue, :reindex}}
    else
      {:noreply, %{index: index}}
    end
  end

  def handle_continue(:reindex, state) do
    {:noreply,
     AshHq.Docs.Dsl.read!(load: :extension_type)
     |> Enum.concat(AshHq.Docs.Option.read!(load: :extension_type))
     |> index(state)}
  end

  def handle_cast({:index, doc}, state) do
    {:noreply, index(state, doc)}
  end

  defp index(doc_or_docs, %{index: index} = state) do
    docs =
      Enum.map(List.wrap(doc_or_docs), fn doc ->
        type =
          case doc do
            %AshHq.Docs.Dsl{} ->
              "dsl"

            %AshHq.Docs.Option{} ->
              "option"
          end

        %{
          "id" => doc.id,
          "name" => doc.name,
          "extension_type" => doc.extension_type,
          "path" => Enum.join(doc.path, ">"),
          "doc" => doc.doc || "",
          "library_version_id" => doc.library_version_id,
          "type" => type
        }
        |> IO.inspect()
      end)

    index =
      index
      |> Index.add_documents(docs)
      |> IndexManager.update()

    %{state | index: index}
  end
end
