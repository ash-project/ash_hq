require Logger
[name, version, file, branch] = System.argv()

Application.put_env(:dsl, :name, name)

if branch == "true" do
  Mix.install([
    {String.to_atom(name), github: "ash-project/#{name}", ref: version}
  ], force: true,
    system_env: [
      {"MIX_QUIET", "true"}
    ])
else
  Mix.install([
    {String.to_atom(name), "== #{version}"}
  ], system_env: [
    {"MIX_QUIET", "true"}
  ])
end

defmodule Utils do
  def try_apply(func, default \\ nil) do
    func.()
  rescue
    _ ->
      default
  end

  def build(extension, order) do
    extension_name = extension.name

    %{
      name: extension_name,
      target: extension[:target],
      default_for_target: extension[:default_for_target?] || false,
      type: extension[:type],
      order: order,
      doc: module_docs(extension.module) || "No documentation",
      dsls: build_sections(extension.module.sections())
    }
  end

  defp build_sections(sections, path \\ []) do
    sections
    |> Enum.with_index()
    |> Enum.flat_map(fn {section, index} ->
      [%{
        name: section.name,
        options: schema(section.schema, path ++ [section.name]),
        doc: section.describe || "No documentation",
        type: :section,
        order: index,
        examples: examples(section.examples),
        path: path
      }] ++
      build_entities(section.entities, path ++ [section.name]) ++
      build_sections(section.sections, path ++ [section.name])
    end)
  end

  defp build_entities(entities, path) do
    entities
    |> Enum.with_index()
    |> Enum.flat_map(fn {entity, index} ->
      [%{
        name: entity.name,
        recursive_as: Map.get(entity, :recursive_as),
        examples: examples(entity.examples),
        order: index,
        doc: entity.describe || "No documentation",
        args: entity.args,
        type: :entity,
        path: path,
        options: schema(entity.schema, path ++ [entity.name]),
      }] ++ build_entities(List.flatten(Keyword.values(entity.entities)), path ++ [entity.name])
    end)
  end

  defp examples(examples) do
    Enum.map(examples, fn {title, example} ->
      "#{title}<>\n<>#{example}"

      example ->
        example
    end)
  end

  defp schema(schema, path) do
    schema
    |> Enum.with_index()
    |> Enum.map(fn {{name, value}, index} ->
      %{
        name: name,
        path: path,
        order: index,
        type: value[:type_name] || type(value[:type]),
        doc: value[:doc] || "No documentation",
        required: value[:required] || false,
        default: inspect(value[:default])
      }
    end)
  end

  def module_docs(module) do
    {:docs_v1, _, :elixir, _, %{"en" => docs}, _, _} = Code.fetch_docs(module)
    docs
  rescue
    _ -> "No Documentation"
  end

  defp type({:behaviour, mod}), do: Module.split(mod) |> List.last()
  defp type({:ash_behaviour, mod}), do: Module.split(mod) |> List.last()
  defp type({:ash_behaviour, mod, _builtins}), do: Module.split(mod) |> List.last()
  defp type({:custom, _, _, _}), do: "any"
  defp type(:ash_type), do: "Type"
  defp type(:ash_resource), do: "Resource"
  defp type(:any), do: "any"
  defp type(:keyword_list), do: "Keyword List"
  defp type({:keyword_list, _schema}), do: "Keyword List"
  defp type(:non_empty_keyword_list), do: "Keyword List"
  defp type(:atom), do: "Atom"
  defp type(:string), do: "String"
  defp type(:boolean), do: "Boolean"
  defp type(:integer), do: "Integer"
  defp type(:non_neg_integer), do: "Non Negative Integer"
  defp type(:pos_integer), do: "Positive Integer"
  defp type(:float), do: "Float"
  defp type(:timeout), do: "Timeout"
  defp type(:pid), do: "Pid"
  defp type(:mfa), do: "MFA"
  defp type(:mod_arg), do: "Module and Arguments"
  defp type({:fun, arity}), do: "Function/#{arity}"
  defp type({:one_of, choices}), do: type({:in, choices})
  defp type({:in, choices}), do: Enum.map_join(choices, " | ", &inspect/1)
  defp type({:or, subtypes}), do: Enum.map_join(subtypes, " | ", &type/1)
  defp type({:list, subtype}), do: type(subtype) <> "[]"

  def doc_index?(module) do
    Ash.Helpers.implements_behaviour?(module, Ash.DocIndex) && module.for_library() == Application.get_env(:dsl, :name)
  end
end

dsls =
  for [app] <- :ets.match(:ac_tab, {{:loaded, :"$1"}, :_}),
      {:ok, modules} = :application.get_key(app, :modules),
      module <- Enum.filter(modules, &Utils.doc_index?/1) do
    module
  end

case Enum.at(dsls, 0) do
  nil ->
    File.write!(file, Base.encode64(:erlang.term_to_binary(nil)))

  dsl ->
    extensions = dsl.extensions()

    acc = %{
      doc: Utils.module_docs(dsl),
      guides: []
    }

    acc =
      Utils.try_apply(fn -> dsl.guides() end, [])
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {guide, order}, acc ->
         Map.update!(acc, :guides, fn guides ->
          [Map.put(guide, :order, order) | guides]
        end)
      end)

    data =
      extensions
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {extension, i}, acc ->
        acc
        |> Map.put_new(:extensions, [])
        |> Map.update!(:extensions, fn extensions ->
          [Utils.build(extension, i) | extensions]
        end)
      end)


    File.write!(file, Base.encode64(:erlang.term_to_binary(data)))
end
