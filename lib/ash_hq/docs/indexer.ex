defmodule AshHq.Docs.Indexer do
  @moduledoc "Indexes content and serves up a search interface"
  use GenServer

  require Ash.Query

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(_) do
    {:ok, %{haystack: haystack()}, {:continue, :index}}
  end

  def haystack do
    Haystack.index(Haystack.new(), :search, fn index ->
      index
      |> Haystack.Index.ref(Haystack.Index.Field.term("id"))
      |> Haystack.Index.field(Haystack.Index.Field.new("name"))
      |> Haystack.Index.field(Haystack.Index.Field.new("call_name"))
      |> Haystack.Index.field(Haystack.Index.Field.new("doc"))
      |> Haystack.Index.field(Haystack.Index.Field.new("library_name"))
      |> Haystack.Index.storage(storage())
    end)
  end

  def storage do
    Haystack.Storage.ETS.new(name: :search, table: :search)
  end

  def search(search) do
    tokens = Haystack.Tokenizer.tokenize(search)
    tokens = Haystack.Transformer.pipeline(tokens, Haystack.Transformer.default())

    Haystack.index(haystack(), :search, fn index ->
      query =
        Enum.reduce(tokens, Haystack.Query.Clause.new(:any), fn token, clause ->
          Enum.reduce(
            Map.values(Map.take(index.fields, ["name", "call_name", "description"])),
            clause,
            fn field, clause ->
              Haystack.Query.Clause.expressions(clause, [
                Haystack.Query.Expression.new(:match, field: field.k, term: token.v)
              ])
            end
          )
        end)

      Haystack.Query.new()
      |> Haystack.Query.clause(query)
      |> Haystack.Query.run(index)
    end)
    |> Stream.map(fn item ->
      [type, id] = String.split(item.ref, "|")
      %{id: id, type: type, score: item.score}
    end)
    |> Enum.group_by(& &1.type)
    |> Enum.flat_map(fn {type, items} ->
      resource =
        case type do
          "dsl" -> AshHq.Docs.Dsl
          "guide" -> AshHq.Docs.Guide
          "option" -> AshHq.Docs.Option
          "module" -> AshHq.Docs.Module
          "mix_task" -> AshHq.Docs.MixTask
          "function" -> AshHq.Docs.Function
        end

      ids = Enum.map(items, & &1.id)

      scores = Map.new(items, &{&1.id, &1.score})

      resource
      |> Ash.Query.filter(id in ^ids)
      |> Ash.Query.load(AshHq.Docs.Extensions.Search.load_for_search(resource))
      |> AshHq.Docs.read!()
      |> Enum.map(fn item ->
        Ash.Resource.put_metadata(item, :search_score, scores[item.id])
      end)
    end)
    |> Enum.sort_by(&{!exact_match?(&1, search), -&1.__metadata__.search_score})
  end

  defp exact_match?(record, search) do
    record
    |> Map.take([:name, :call_name])
    |> Map.values()
    |> Enum.any?(fn value ->
      is_binary(value) &&
        String.downcase(value) == String.downcase(String.trim_trailing(search, "("))
    end)
  end

  def handle_continue(:index, state) do
    {:noreply, index(state)}
  end

  def handle_info(:index, state) do
    {:noreply, index(state)}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp index(state) do
    haystack =
      Haystack.index(state.haystack, :search, fn index ->
        [
          dsls(),
          guides(),
          options(),
          modules(),
          mix_tasks(),
          functions()
        ]
        |> Stream.concat()
        |> Stream.chunk_every(100)
        |> Enum.each(&Haystack.Index.add(index, &1))
      end)

    %{state | haystack: haystack}
  after
    Process.send_after(self(), :index, :timer.hours(6))
  end

  defp dsls do
    AshHq.Docs.Dsl
    |> Ash.Query.load([:library_name, :extension_module])
    |> AshHq.Docs.stream!()
    |> Stream.map(fn dsl ->
      %{
        "id" => id("dsl", dsl.id),
        "name" => dsl.name,
        "library_name" => dsl.library_name,
        "doc" => dsl.doc,
        "call_name" => "#{dsl.extension_module}.#{dsl.sanitized_path}.#{dsl.name}"
      }
    end)
  end

  defp guides do
    AshHq.Docs.Guide
    |> Ash.Query.load(library_version: :library)
    |> AshHq.Docs.stream!()
    |> Stream.map(fn guide ->
      %{
        "id" => id("guide", guide.id),
        "name" => guide.name,
        "library_name" => guide.library_version.library.name,
        "doc" => guide.text
      }
    end)
  end

  defp options do
    AshHq.Docs.Option
    |> Ash.Query.load([:library_name, :extension_module])
    |> AshHq.Docs.stream!()
    |> Stream.map(fn option ->
      %{
        "id" => id("option", option.id),
        "name" => option.name,
        "library_name" => option.library_name,
        "doc" => option.doc,
        "call_name" => "#{option.extension_module}.#{option.sanitized_path}.#{option.name}"
      }
    end)
  end

  defp modules do
    AshHq.Docs.Module
    |> Ash.Query.load([:library_name])
    |> AshHq.Docs.stream!()
    |> Stream.map(fn module ->
      %{
        "id" => id("module", module.id),
        "name" => module.name,
        "library_name" => module.library_name,
        "doc" => module.doc,
        "call_name" => module.name
      }
    end)
  end

  defp mix_tasks do
    AshHq.Docs.MixTask
    |> Ash.Query.load([:library_name])
    |> AshHq.Docs.stream!()
    |> Stream.map(fn mix_task ->
      %{
        "id" => id("mix_task", mix_task.id),
        "name" => mix_task.module_name,
        "library_name" => mix_task.library_name,
        "doc" => mix_task.doc,
        "call_name" => mix_task.name
      }
    end)
  end

  defp functions do
    AshHq.Docs.Function
    |> Ash.Query.load([:library_name, :call_name])
    |> AshHq.Docs.stream!()
    |> Stream.map(fn function ->
      %{
        "id" => id("function", function.id),
        "name" => function.name,
        "library_name" => function.library_name,
        "doc" => function.doc,
        "call_name" => function.call_name
      }
    end)
  end

  defp id(type, id), do: "#{type}|#{id}"
end
