require Logger
[name, version, file] = System.argv()

Application.put_env(:dsl, :name, name)

Mix.install([
  {String.to_atom(name), "== #{version}"}
], system_env: [
  {"MIX_QUIET", "true"}
])


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
        links: Map.new(section.links || []),
        imports: Enum.map(section.imports, &inspect/1),
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
        imports: [],
        links: Map.new(entity.links || []),
        args: entity.args,
        type: :entity,
        path: path,
        options: add_argument_indices(schema(entity.schema, path ++ [entity.name]), entity.args),
      }] ++ build_entities(List.flatten(Keyword.values(entity.entities)), path ++ [entity.name])
    end)
  end

  defp add_argument_indices(values, []) do
    values
  end

  defp add_argument_indices(values, arguments) do
    Enum.map(values, fn value ->
      case Enum.find_index(arguments, &(&1 == value.name)) do
        nil ->
          value

        arg_index ->
          Map.put(value, :argument_index, arg_index)
      end
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
        links: Map.new(value[:links] || []),
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

  def build_function({{type, name, arity}, line, heads, %{"en" => docs}, _}, file, order) when not(is_nil(type)) and not(is_nil(name)) and not(is_nil(arity)) do
    [%{
      name: to_string(name),
      type: type,
      file: file,
      line: line,
      arity: arity,
      order: order,
      heads: heads,
      doc: docs || "No documentation"
    }]
  end

  def build_function(_, _, _), do: []

  def build_module(module, category, order) do
    {:docs_v1, _, :elixir, _, %{
      "en" => module_doc
    }, _, defs} = Code.fetch_docs(module)

    module_info =
      try do
        module.module_info(:compile)
      rescue
        _ ->
          nil
      end

    file = file(module_info[:source])

    %{
      name: inspect(module),
      doc: module_doc,
      file: file,
      order: order,
      category: category,
      functions: defs |> Enum.with_index() |> Enum.flat_map(fn {definition, i} ->
        build_function(definition, file, i)
      end)
    }
  end

  defp file(nil), do: nil
  defp file(path) do
    this_path = Path.split(__ENV__.file)
    compile_path = Path.split(path)

    this_path
    |> remove_shared_root(compile_path)
    |> Enum.drop_while(&(&1 != "deps"))
    |> Enum.drop(2)
    |> case do
      [] ->
        nil

      other ->
        Path.join(other)
    end
  end

  defp remove_shared_root([left | left_rest], [left | right_rest]) do
    remove_shared_root(left_rest, right_rest)
  end

  defp remove_shared_root(_, remaining), do: remaining

  defp type({:behaviour, mod}), do: Module.split(mod) |> List.last()
  defp type({:spark, mod}), do: Module.split(mod) |> List.last()
  defp type({:spark_behaviour, mod}), do: Module.split(mod) |> List.last()
  defp type({:spark_behaviour, mod, _builtins}), do: Module.split(mod) |> List.last()
  defp type({:custom, _, _, _}), do: "any"
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
  defp type({:mfa_or_fun, arity}), do: "MFA | function/#{arity}"
  defp type(:literal), do: "any literal"
  defp type({:tagged_tuple, tag, type}), do: "{:#{tag}, #{type(type)}}"
  defp type({:spark_type, type, _}), do: inspect(type)
  defp type({:spark_type, type, _, _}), do: inspect(type)

  def doc_index?(module) do
    Spark.implements_behaviour?(module, Spark.DocIndex) && module.for_library() == Application.get_env(:dsl, :name)
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
      guides: [],
      modules: []
    }

    acc =
      Utils.try_apply(fn -> dsl.guides() end, [])
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {guide, order}, acc ->
         Map.update!(acc, :guides, fn guides ->
          [Map.put(guide, :order, order) | guides]
        end)
      end)

    acc =
      Utils.try_apply(fn -> dsl.code_modules() end, [])
      |> Enum.reduce(acc, fn {category, modules}, acc ->
        modules
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {module, order}, acc ->
          Map.update!(acc, :modules, fn modules ->
            [Utils.build_module(module, category, order) | modules]
          end)
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
