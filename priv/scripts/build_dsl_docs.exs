require Logger
[name, version, file, mix_project, repo_org | rest] = System.argv()

github_sha =
  case rest do
    [github_sha] ->
      github_sha

    _ ->
      nil
  end

mix_project = Module.concat([mix_project])

Application.put_env(:dsl, :name, name)

if github_sha do
  Mix.install(
    [
      {String.to_atom(name), github: "#{repo_org}/#{name}", sha: github_sha}
    ],
    force: true,
    system_env: [
      {"MIX_QUIET", "true"}
    ]
  )
else
  Mix.install(
    [
      {String.to_atom(name), "== #{version}"}
    ],
    force: true,
    system_env: [
      {"MIX_QUIET", "true"}
    ]
  )
end

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

  def build(extension, all_extensions, order) do
    %{
      name: extension.name,
      target: extension[:target],
      module: inspect(extension.module),
      default_for_target: extension[:default_for_target?] || false,
      type: extension[:type],
      order: order,
      doc: module_docs(extension.module) || "No documentation",
      dsls: build_sections(extension.module.sections(), extension.module, all_extensions)
    }
  end

  defp build_sections(sections, this_extension_module, all_extensions, path \\ []) do
    sections
    |> Enum.with_index()
    |> Enum.flat_map(fn {section, index} ->
      section_path = path ++ [section.name]

      entities =
        all_extensions
        |> Enum.flat_map(fn extension ->
          extension.module.dsl_patches()
          |> Enum.filter(&match?(%Spark.Dsl.Patch.AddEntity{section_path: ^section_path}, &1))
          |> Enum.map(fn %{entity: entity} ->
            if extension.module == this_extension_module do
              entity
            else
              Map.put(entity, :__requires_extension__, inspect(extension.module))
            end
          end)
        end)
        |> then(fn entities ->
          Enum.concat(section.entities, entities)
        end)

      [
        %{
          name: section.name,
          options: schema(section.schema, section_path),
          links: Map.new(section.links || []),
          imports: Enum.map(section.imports, &inspect/1),
          type: :section,
          order: index,
          doc: docs_with_examples(section.describe || "", examples(section.examples)),
          path: path
        }
      ] ++
        build_entities(entities, section_path) ++
        build_sections(section.sections, this_extension_module, all_extensions, section_path)
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
        maybe_add_examples(examples)

      doc ->
        """
        #{doc}

        #{maybe_add_examples(examples)}
        """
    end
  end

  defp maybe_add_examples([]), do: ""

  defp maybe_add_examples(examples) do
    "Examples:\n\n#{Enum.map_join(examples, "\n\n", &wrap_code/1)}"
  end

  defp build_entities(entities, path) do
    entities
    |> Enum.with_index()
    |> Enum.flat_map(fn {entity, index} ->
      [build_entity(entity, path, index)] ++
        build_entities(List.flatten(Keyword.values(entity.entities)), path ++ [entity.name])
    end)
  end

  defp build_entity(entity, path, index) do
    keys_to_remove = Enum.map(entity.auto_set_fields || [], &elem(&1, 0))
    option_schema = Keyword.drop(entity.schema || [], keys_to_remove)

    %{
      name: entity.name,
      recursive_as: Map.get(entity, :recursive_as),
      doc: docs_with_examples(entity.describe || "", examples(entity.examples)),
      order: index,
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
        Enum.reduce(entity.args, %{}, fn
          {:optional, name, default}, acc ->
            Map.put(acc, name, inspect(default))

          _, acc ->
            acc
        end),
      type: :entity,
      path: path,
      options:
        option_schema
        |> schema(path ++ [entity.name])
        |> add_argument_indices(entity.args)
    }
    |> then(fn config ->
      case Map.fetch(entity, :__requires_extension__) do
        {:ok, value} ->
          Map.put(config, :requires_extension, value)

        :error ->
          config
      end
    end)
  end

  defp add_argument_indices(values, []) do
    values
  end

  defp add_argument_indices(values, arguments) do
    Enum.map(values, fn value ->
      case Enum.find_index(arguments, fn
             {:optional, name, _} ->
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
    |> Enum.reject(fn {_key, config} ->
      config[:hide]
    end)
    |> Enum.with_index()
    |> Enum.map(fn {{name, value}, index} ->
      %{
        name: name,
        path: path,
        order: index,
        links: Map.new(value[:links] || []),
        type: value[:type_name] || type(value[:type]),
        doc: add_default(value[:doc] || "No documentation", value[:default]),
        required: value[:required] || false,
        default: inspect(value[:default])
      }
    end)
  end

  defp add_default(docs, nil), do: docs

  defp add_default(docs, default) do
    "#{docs} Defaults to `#{inspect(default)}`."
  end

  def module_docs(module) do
    {:docs_v1, _, :elixir, _, %{"en" => docs}, _, _} = Code.fetch_docs(module)
    docs
  rescue
    _ -> ""
  end

  def build_function({_, _, _, :hidden, _}, _, _, _, _, _), do: []

  def build_function(
        {{type, name, arity}, line, heads, docs, metadata},
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

    line =
      cond do
        is_integer(line) ->
          line

        is_list(line) ->
          line[:location]

        true ->
          nil
      end

    [
      %{
        name: to_string(name),
        type: type,
        file: file,
        line: line,
        arity: arity,
        order: order,
        doc: docs || "No documentation",
        deprecated: Map.get(metadata, :deprecated)
      }
    ]
  end

  def build_function(_, _, _, _, _, _), do: []

  def build_module(module, category, order) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, :elixir, _, docs, _, defs} ->
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

        {:ok,
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
         }}

      _ ->
        :error
    end
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
      module_name: inspect(mix_task),
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
  defp type(:map), do: "Map"
  defp type(:struct), do: "Struct"
  defp type({:struct, struct}), do: "#{inspect(struct)}"
  defp type(nil), do: "nil"
  defp type({:fun, arity}), do: "Function/#{arity}"
  defp type({:one_of, choices}), do: type({:in, choices})
  defp type({:in, choices}), do: Enum.map_join(choices, " | ", &inspect/1)
  defp type({:or, subtypes}), do: Enum.map_join(subtypes, " | ", &type/1)
  defp type({:list, subtype}), do: type(subtype) <> "[]"
  defp type({:literal, value}), do: inspect(value)

  defp type({:wrap_list, subtype}) do
    str = type(subtype)
    str <> "[] | " <> str
  end

  defp type({:list_of, subtype}), do: type({:list, subtype})
  defp type({:mfa_or_fun, arity}), do: "MFA | function/#{arity}"
  defp type(:literal), do: "any literal"
  defp type({:tagged_tuple, tag, type}), do: "{:#{tag}, #{type(type)}}"
  defp type({:tuple, types}), do: "{#{Enum.map_join(types, ", ", &type/1)}}"
  defp type({:spark_type, type, _}), do: inspect(type)
  defp type({:spark_type, type, _, _}), do: inspect(type)

  def modules_for(all_modules, modules) do
    case modules do
      %Regex{} = regex ->
        Enum.filter(all_modules, fn module ->
          Regex.match?(regex, inspect(module)) || Regex.match?(regex, to_string(module))
        end)

      other ->
        if is_list(modules) do
          Enum.flat_map(modules, &modules_for(all_modules, &1))
        else
          other
          |> List.wrap()
          |> Enum.map(&Module.concat(List.wrap(&1)))
        end
    end
  end

  def guides(mix_project, name) do
    root_dir = File.cwd!()

    app_dir =
      name
      |> Application.app_dir()
      |> Path.join("../../../../deps/#{name}")
      |> Path.expand()

    try do
      File.cd!(app_dir)

      extras =
        mix_project.project[:docs][:extras]
        |> Stream.map(fn
          {file, config} ->
            {file, config}

          file ->
            {file, []}
        end)
        |> Stream.reject(fn {item, _} ->
          Path.extname(to_string(item)) != ".md"
        end)
        |> Stream.reject(fn {item, _} ->
          String.contains?(to_string(item), "hexdocs")
        end)
        |> Enum.reject(fn
          {_name, config} ->
            config[:ash_hq?] == false || config[:ash_hq] == false

          _ ->
            false
        end)
        |> Enum.map(fn
          {file, config} ->
            file = to_string(file)

            config =
              if config[:title] do
                Keyword.put(config, :name, config[:title])
              else
                title =
                  file
                  |> Path.basename(".md")
                  |> String.split(~r/[-_]/)
                  |> Enum.map(&String.capitalize/1)
                  |> Enum.join(" ")
                  |> case do
                    "F A Q" ->
                      "FAQ"

                    other ->
                      other
                  end

                Keyword.put(config, :name, title)
              end

            {to_string(file), config}

          file ->
            file = to_string(file)

            title =
              file
              |> Path.basename(".md")
              |> String.split(~r/[-_]/)
              |> Enum.map(&String.capitalize/1)
              |> Enum.join(" ")
              |> case do
                "F A Q" ->
                  "FAQ"

                other ->
                  other
              end

            {file, name: title}
        end)

      groups_for_extras =
        mix_project.project[:docs][:groups_for_extras]
        |> List.wrap()
        |> Kernel.++([{"Miscellaneous", ~r/.*/}])

      groups_for_extras
      |> Enum.reduce({extras, []}, fn {group, matcher}, {remaining_extras, acc} ->
        matches_for_group =
          matcher
          |> List.wrap()
          |> Enum.flat_map(&take_matching(remaining_extras, &1))
          # only reason I'm using uniq_by here is because the module docs for uniq_by says
          # "the first unique element is kept", and I need those semantics.
          # uniq might be the same way, but the docs don't say it.
          |> Enum.uniq_by(& &1)

        {remaining_extras -- matches_for_group, [{group, matches_for_group} | acc]}
      end)
      |> elem(1)
      |> Enum.reverse()
      |> Enum.flat_map(fn {category, matches} ->
        matches
        |> Enum.with_index()
        |> Enum.map(fn {{path, config}, index} ->
          route =
            path
            |> Path.absname()
            |> String.trim_leading(app_dir)
            |> String.trim_leading("/documentation/")
            |> String.trim_trailing(".md")

          config
          |> Map.new()
          |> Map.put(:order, index)
          |> Map.put(:route, route)
          |> Map.put(:category, category)
          |> Map.put(:text, File.read!(path))
        end)
      end)
    after
      File.cd!(root_dir)
    end
  end

  defp take_matching(extras, matcher) when is_binary(matcher) do
    extras
    |> Enum.filter(fn {name, _} ->
      name == matcher
    end)
  end

  defp take_matching(extras, %Regex{} = matcher) do
    Enum.filter(extras, fn {name, _} -> Regex.match?(matcher, name) end)
  end
end

acc = %{
  extensions: [],
  guides: Utils.guides(mix_project, String.to_atom(name)),
  modules: [],
  mix_tasks: []
}

extensions =
  mix_project.project[:docs][:spark][:extensions] || mix_project.project[:docs][:spark_extensions]

{:ok, all_modules} =
  name
  |> String.to_atom()
  |> :application.get_key(:modules)

all_modules =
  all_modules
  |> Kernel.||([])
  |> Enum.reject(fn module ->
    Enum.find(extensions || [], &(&1.module == module))
  end)

all_modules =
  all_modules
  |> Enum.filter(fn module ->
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, _, :none, _, _} ->
        false

      {:docs_v1, _, _, _, type, _, _} when type != :hidden ->
        true

      _ ->
        false
    end
  end)

acc =
  mix_project.project[:docs][:groups_for_modules]
  |> Enum.reject(fn
    {"Internals", _} ->
      true

    {:Internals, _} ->
      true

    _ ->
      false
  end)
  |> Enum.reduce(acc, fn {category, modules}, acc ->
    modules = Utils.modules_for(all_modules, modules)

    modules
    |> Enum.with_index()
    |> Enum.reduce(acc, fn {module, order}, acc ->
      case Utils.build_module(module, category, order) do
        {:ok, built} ->
          Map.update!(acc, :modules, fn modules ->
            [built | modules]
          end)

        _ ->
          acc
      end
    end)
  end)

acc =
  mix_project.project[:docs][:spark][:mix_tasks]
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
  |> Kernel.||([])
  |> Enum.with_index()
  |> Enum.reduce(acc, fn {extension, i}, acc ->
    acc
    |> Map.put_new(:extensions, [])
    |> Map.update!(:extensions, fn acc ->
      [Utils.build(extension, extensions, i) | acc]
    end)
  end)

File.write!(file, Base.encode64(:erlang.term_to_binary(data)))
