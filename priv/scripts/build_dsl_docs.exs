require Logger
[name, version, file] = System.argv()

Application.put_env(:dsl, :name, name)

Mix.install(
  [
    {String.to_atom(name), "== #{version}"}
  ],
  force: true,
  system_env: [
    {"MIX_QUIET", "true"}
  ]
)

defmodule Types do
  def for_module(module) do
    {:ok, types} = Code.Typespec.fetch_types(module)
    types
  rescue
    _ ->
      []
  end

  def callbacks_for_module(module) do
    {:ok, callbacks} = Code.Typespec.fetch_callbacks(module)
    callbacks
  rescue
    _ ->
      []
  end

  def specs_for_module(module) do
    {:ok, specs} = Code.Typespec.fetch_specs(module)
    specs
  rescue
    _ ->
      []
  end

  def additional_heads_for(specs, name, arity) do
    specs
    |> Enum.flat_map(fn
      {{^name, ^arity}, contents} ->
        contents

      _ ->
        []
    end)
    |> Enum.map(fn body ->
      name
      |> Code.Typespec.spec_to_quoted(body)
      |> Macro.to_string()
    end)
  end

  def code_for(types, name, arity) do
    case Enum.find_value(types, fn
           {:type, {^name, _, args} = type} ->
             if Enum.count(args) == arity do
               type
             end

           _other ->
             false
         end) do
      nil ->
        ""

      type ->
        type |> Code.Typespec.type_to_quoted() |> Macro.to_string()
    end
  end
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
      [
        %{
          name: section.name,
          options: schema(section.schema, path ++ [section.name]),
          links: Map.new(section.links || []),
          imports: Enum.map(section.imports, &inspect/1),
          type: :section,
          order: index,
          doc: docs_with_examples(section.describe || "", examples(section.examples)),
          path: path
        }
      ] ++
        build_entities(section.entities, path ++ [section.name]) ++
        build_sections(section.sections, path ++ [section.name])
    end)
  end

  defp wrap_code(text) do
    """
    ```elixir
    #{text}
    ```
    """
  end

  defp docs_with_examples(doc, examples) do
    case doc do
      nil ->
        "### Examples\n#{Enum.map_join(examples, "\n\n", &wrap_code/1)}"

      doc ->
        """
        #{doc}
        # Examples
        #{Enum.map_join(examples, "\n\n", &wrap_code/1)}
        """
    end
  end

  defp build_entities(entities, path) do
    entities
    |> Enum.with_index()
    |> Enum.flat_map(fn {entity, index} ->
      keys_to_remove = Enum.map(entity.auto_set_fields || [], &elem(&1, 0))

      option_schema = Keyword.drop(entity.schema || [], keys_to_remove)

      [
        %{
          name: entity.name,
          recursive_as: Map.get(entity, :recursive_as),
          order: index,
          doc: docs_with_examples(entity.describe || "", examples(entity.examples)),
          imports: [],
          links: Map.new(entity.links || []),
          args:
            Enum.map(entity.args, fn
              {:optional, name, _} ->
                name

              {:optional, name} ->
                name

              name ->
                name
            end),
          optional_args:
            Enum.flat_map(entity.args, fn
              {:optional, name, _} ->
                [name]

              {:optional, name} ->
                [name]

              _ ->
                []
            end),
          arg_defaults:
            Enum.reduce(entity.args, %{},
            fn {:optional, name, default}, acc ->
                Map.put(acc, name, inspect(default))

              _, acc ->
                acc
            end),
          type: :entity,
          path: path,
          options: add_argument_indices(schema(option_schema, path ++ [entity.name]), entity.args)
        }
      ] ++ build_entities(List.flatten(Keyword.values(entity.entities)), path ++ [entity.name])
    end)
  end

  defp add_argument_indices(values, []) do
    values
  end

  defp add_argument_indices(values, arguments) do
    Enum.map(values, fn value ->
      case Enum.find_index(arguments, fn {:optional, name, _} ->
          name == value.name

        {:optional, name} ->
          name == value.name

        name ->
          name == value.name
      end) do
        nil ->
          value

        arg_index ->
          Map.put(value, :argument_index, arg_index)
      end
    end)
  end

  defp examples(examples) do
    Enum.map(examples, fn
      {title, example} ->
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
    _ -> ""
  end

  def build_function({_, _, _, :hidden, _}, _, _, _, _, _), do: []

  def build_function(
        {{type, name, arity}, line, heads, docs, _},
        file,
        types,
        callbacks,
        specs,
        order
      )
      when not is_nil(type) and not is_nil(name) and not is_nil(arity) do
    docs =
      case docs do
        %{"en" => en} ->
          en

        _ ->
          ""
      end

    heads = List.wrap(heads)

    heads =
      case type do
        :type ->
          case Types.code_for(types, name, arity) do
            "" ->
              heads

            head ->
              [head | heads]
          end

        :callback ->
          heads ++ Types.additional_heads_for(callbacks, name, arity)

        :function ->
          heads ++ Types.additional_heads_for(specs, name, arity)

        :macro ->
          heads ++ Types.additional_heads_for(specs, name, arity)

        _ ->
          heads
      end

    heads =
      heads
      |> Enum.map(fn head ->
        head
        |> Code.format_string!(line_length: 68)
        |> IO.iodata_to_binary()
      end)
      |> case do
        [] ->
          ["#{name}/#{arity}"]

        heads ->
          heads
      end

    docs = """
    ```elixir
    #{Enum.join(heads, "\n")}
    ```

    <!--- heads-end -->

    #{docs}
    """

    [
      %{
        name: to_string(name),
        type: type,
        file: file,
        line: line,
        arity: arity,
        order: order,
        doc: docs || "No documentation"
      }
    ]
  end

  def build_function(_, _, _, _, _, _), do: []

  def build_module(module, category, order) do
    {:docs_v1, _, :elixir, _, docs, _, defs} = Code.fetch_docs(module)

    module_doc =
      case docs do
        %{"en" => en} ->
          en

        _ ->
          ""
      end

    module_info =
      try do
        module.module_info(:compile)
      rescue
        _ ->
          nil
      end

    file = file(module_info[:source])

    types = Types.for_module(module)
    callbacks = Types.callbacks_for_module(module)
    typespecs = Types.specs_for_module(module)

    %{
      name: inspect(module),
      doc: module_doc,
      file: file,
      order: order,
      category: category,
      functions:
        defs
        |> Enum.with_index()
        |> Enum.flat_map(fn {definition, i} ->
          build_function(definition, file, types, callbacks, typespecs, i)
        end)
    }
  end

  def build_mix_task(mix_task, category, order) do
    {:docs_v1, _, :elixir, _, docs, _, _} = Code.fetch_docs(mix_task)

    module_doc =
      case docs do
        %{"en" => en} ->
          en

        _ ->
          ""
      end

    module_info =
      try do
        mix_task.module_info(:compile)
      rescue
        _ ->
          nil
      end

    file = file(module_info[:source])

    %{
      name: Mix.Task.task_name(mix_task),
      doc: module_doc,
      file: file,
      order: order,
      category: category
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
  defp type(:module), do: "Module"

  defp type({:spark_function_behaviour, mod, {_, arity}}) do
    type({:or, [{:fun, arity}, {:spark_behaviour, mod}]})
  end

  defp type({:spark_function_behaviour, mod, _builtins, {_, arity}}) do
    type({:or, [{:fun, arity}, {:spark_behaviour, mod}]})
  end

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
  defp type({:list_of, subtype}), do: type({:list, subtype})
  defp type({:mfa_or_fun, arity}), do: "MFA | function/#{arity}"
  defp type(:literal), do: "any literal"
  defp type({:tagged_tuple, tag, type}), do: "{:#{tag}, #{type(type)}}"
  defp type({:spark_type, type, _}), do: inspect(type)
  defp type({:spark_type, type, _, _}), do: inspect(type)

  def doc_index?(module) do
    Spark.implements_behaviour?(module, Spark.DocIndex) &&
      module.for_library() == Application.get_env(:dsl, :name)
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
      modules: [],
      mix_tasks: []
    }

    default_guide = Utils.try_apply(fn -> dsl.default_guide() end)

    acc =
      Utils.try_apply(fn -> dsl.guides() end, [])
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {guide, order}, acc ->
        Map.update!(acc, :guides, fn guides ->
          guide =
            guide
            |> Map.put(:order, order)
            |> Map.update!(:route, &String.trim_trailing(&1, ".md"))

          guide =
            if guide.route == default_guide.route do
              Map.put(guide, :default, true)
            else
              guide
            end

          [guide | guides]
        end)
      end)

    {:ok, all_modules} =
      name
      |> String.to_atom()
      |> :application.get_key(:modules)

    all_modules =
      Enum.filter(all_modules, fn module ->
        case Code.fetch_docs(module) do
          {:docs_v1, _, _, _, type, _, _} when type != :hidden ->
            true

          _ ->
            false
        end
      end)

    acc =
      Utils.try_apply(fn -> dsl.code_modules() end, [])
      |> Enum.reduce(acc, fn {category, modules}, acc ->
        modules =
          case modules do
            %Regex{} = regex ->
              Enum.filter(all_modules, fn module ->
                Regex.match?(regex, inspect(module)) || Regex.match?(regex, to_string(module))
              end)

            other ->
              List.wrap(other)
          end

        modules
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {module, order}, acc ->
          Map.update!(acc, :modules, fn modules ->
            [Utils.build_module(module, category, order) | modules]
          end)
        end)
      end)

    acc =
      Utils.try_apply(fn -> dsl.mix_tasks() end, [])
      |> List.wrap()
      |> Enum.reduce(acc, fn {category, mix_tasks}, acc ->
        mix_tasks
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {mix_task, order}, acc ->
          Map.update!(acc, :mix_tasks, fn mix_tasks ->
            [Utils.build_mix_task(mix_task, category, order) | mix_tasks]
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
