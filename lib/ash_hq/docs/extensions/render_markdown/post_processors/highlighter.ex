defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.Highlighter do
  @moduledoc false
  # Copied *directly* from nimble_publisher
  # https://github.com/dashbitco/nimble_publisher/blob/v0.1.2/lib/nimble_publisher/highlighter.ex

  use AshHqWeb, :verified_routes

  def highlight(ast, libraries, current_library, current_module) do
    ast
    |> Floki.traverse_and_update(fn
      {"a", attrs, contents} ->
        {"a", rewrite_href_attr(attrs, current_library, libraries), contents}

      {"pre", _, [{:keep, contents}]} ->
        {:keep, ~s(<pre class="code-pre">#{contents}</pre>)}

      {"pre", _, [{"code", attrs, [body]}]} when is_binary(body) ->
        lexer =
          find_value_class(attrs, fn class ->
            case Makeup.Registry.fetch_lexer_by_name(class) do
              {:ok, {lexer, opts}} -> {class, lexer, opts}
              :error -> nil
            end
          end)

        code =
          case lexer do
            {lang, lexer, opts} ->
              render_code(lang, lexer, opts, body)

            nil ->
              if find_value_class(attrs, &(&1 == "inline")) do
                maybe_highlight_module(body, libraries, current_module)
              else
                ~s(<code class="text-black dark:text-white">#{body}</code>)
              end
          end

        {:keep, ~s(<pre class="code-pre">#{code}</pre>)}

      {"code", attrs, [body]} when is_binary(body) ->
        lexer =
          find_value_class(attrs, fn class ->
            case Makeup.Registry.fetch_lexer_by_name(class) do
              {:ok, {lexer, opts}} -> {class, lexer, opts}
              :error -> nil
            end
          end)

        code =
          case lexer do
            {lang, lexer, opts} ->
              render_code(lang, lexer, opts, body)

            nil ->
              if find_value_class(attrs, &(&1 == "inline")) do
                maybe_highlight_module(body, libraries, current_module)
              else
                ~s(<code class="text-black dark:text-white">#{body}</code>)
              end
          end

        {:keep, code}

      other ->
        other
    end)
  end

  defp rewrite_href_attr(attrs, current_library, libraries) do
    Enum.map(attrs, fn
      {"href", value} ->
        {"href", rewrite_href(value, current_library, libraries)}

      other ->
        other
    end)
  end

  @doc false
  def rewrite_href(value, current_library, libraries) do
    uri = URI.parse(value)

    case {uri, Path.split(String.trim_leading(uri.path || "", "/"))} do
      {%{host: "hexdocs.pm"}, [library, guide]} ->
        if Enum.any?(libraries, &(&1.name == library)) do
          if String.ends_with?(guide, ".html") do
            name =
              guide
              |> String.trim_trailing(".html")
              |> AshHqWeb.DocRoutes.sanitize_name()

            url(~p"/docs/guides/#{library}/latest/#{name}")
          end
        else
          value
        end

      {%{host: "hexdocs.pm"}, [library]} ->
        if Enum.any?(libraries, &(&1.name == library)) do
          url(~p"/docs/#{library}/latest")
        else
          value
        end

      {%{host: "hex.pm"}, ["packages", library]} ->
        if Enum.any?(libraries, &(&1.name == library)) do
          url(~p"/docs/#{library}/latest")
        else
          value
        end

      {%{host: "github.com"}, [owner, library]} ->
        if Enum.any?(libraries, &(&1.name == library && &1.repo_org == owner)) do
          url(~p"/docs/#{library}/latest")
        else
          value
        end

      {%{host: "github.com"}, [owner, library, "blob", _, "documentation", guide]} ->
        github_guide_link(value, libraries, owner, library, guide)

      {%{host: "github.com"}, [owner, library, "tree", _, "documentation", guide]} ->
        github_guide_link(value, libraries, owner, library, guide)

      {%{host: nil}, ["documentation", _type, guide]} ->
        github_guide_link(value, libraries, nil, current_library, guide)

      {%{host: nil}, [guide]} ->
        github_guide_link(value, libraries, nil, current_library, guide)

      _ ->
        value
    end
  end

  defp github_guide_link(value, _libraries, _owner, nil, _guide) do
    value
  end

  defp github_guide_link(value, libraries, owner, library, guide) do
    guide = String.trim_trailing(guide, ".md")

    if owner do
      if Enum.any?(libraries, &(&1.name == library && &1.repo_org == owner)) do
        url(~p"/docs/guides/#{library}/latest/#{guide}")
      else
        value
      end
    else
      if Enum.any?(libraries, &(&1.name == library)) do
        url(~p"/docs/guides/#{library}/latest/#{guide}")
      else
        value
      end
    end
  end

  defp find_value_class(attrs, func) do
    Enum.find_value(attrs, fn
      {"class", classes} ->
        classes
        |> String.split(" ")
        |> Enum.find_value(func)

      _ ->
        nil
    end)
  end

  def maybe_highlight_module(code, libraries, current_module) do
    code_without_c =
      case code do
        "c:" <> rest ->
          rest

        _ ->
          nil
      end

    code_without_type =
      case code do
        "t:" <> rest ->
          rest

        _ ->
          nil
      end

    code_without_dsl =
      case code do
        "d:" <> rest ->
          rest

        _ ->
          nil
      end

    try_parse_multi(
      [
        {"callback", code_without_c},
        {"type", code_without_type},
        {"dsl", code_without_dsl},
        {nil, code}
      ],
      libraries,
      current_module
    )
  end

  defp try_parse_multi([{_, nil} | rest], libraries, current_module),
    do: try_parse_multi(rest, libraries, current_module)

  defp try_parse_multi([{"dsl", code} | rest], libraries, current_module) do
    code = String.trim(code)

    with [code | maybe_anchor] when length(rest) in [0, 1] <- String.split(code, "|", trim: true),
         {module, dsl_path} <-
           code
           |> String.split(".")
           |> Enum.split_while(&capitalized?/1) do
      if module == [] and !current_module do
        ~s[<code class="inline">#{code}</code>]
      else
        anchor =
          case maybe_anchor do
            [] ->
              ""

            option ->
              "##{option}"
          end

        module =
          case module do
            [] ->
              current_module

            module ->
              Enum.join(module, ".")
          end

        dsl_dots = Enum.join(dsl_path ++ List.wrap(maybe_anchor), ".")
        dsl_path = Enum.join(dsl_path, "/")

        code =
          case maybe_anchor do
            [] ->
              code

            anchor ->
              "#{code}.#{anchor}"
          end

        code =
          ~s[<code class="inline maybe-dsl text-black dark:text-white" data-module="#{module}" data-dsl="#{dsl_dots}">#{code}</code>]

        case library_for(module, libraries) do
          nil ->
            code

          library ->
            link =
              url(
                ~p'/docs/dsl/#{library.name}/latest/#{AshHqWeb.DocRoutes.sanitize_name(module)}'
              ) <> "/" <> dsl_path <> anchor

            ~s[<a href="#{link}">#{code}</a>]
        end
      end
    else
      _ ->
        ~s[<code class="inline">#{code}</code>]
    end
  end

  defp try_parse_multi([{type, code} | rest], libraries, current_module) do
    case Code.string_to_quoted(code) do
      {:ok, {fun, _, []}} when is_atom(fun) ->
        arity = 0

        if current_module do
          function_href(
            ~s[<code #{function_type(type)} class="inline maybe-call text-black dark:text-white" data-module="#{current_module}" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>],
            libraries,
            type,
            current_module,
            fun,
            arity
          )
        else
          ~s[<code #{function_type(type)} class="inline maybe-local-call text-black dark:text-white" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>]
        end

      {:ok,
       {:/, _,
        [
          {{:., _, [{:__aliases__, _, parts}, fun]}, _, []},
          arity
        ]}}
      when is_atom(fun) and is_integer(arity) ->
        function_href(
          ~s[<code #{function_type(type)} class="inline maybe-call text-black dark:text-white" data-module="#{Enum.join(parts, ".")}" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>],
          libraries,
          type,
          Enum.join(parts, "."),
          fun,
          arity
        )

      {:ok, {:/, _, [{fun, _, nil}, arity]}} when is_atom(fun) and is_integer(arity) ->
        function_href(
          if current_module do
            ~s[<code #{function_type(type)} class="inline maybe-call text-black dark:text-white" data-module="#{current_module}" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>]
          else
            ~s[<code #{function_type(type)} class="inline maybe-local-call text-black dark:text-white" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>]
          end,
          libraries,
          type,
          current_module,
          fun,
          arity
        )

      {:ok, {:__aliases__, _, parts}} ->
        module_name = Enum.join(parts, ".")

        module_href(
          ~s[<code class="inline maybe-module text-black dark:text-white" data-module="#{module_name}">#{code}</code>],
          libraries,
          type,
          module_name
        )

      _ ->
        if rest == [] do
          ~s[<code class="inline text-black dark:text-white">#{code}</code>]
        else
          try_parse_multi(rest, libraries, current_module)
        end
    end
  rescue
    _ ->
      ~s[<code class="inline">#{code}</code>]
  end

  defp capitalized?(string) do
    str =
      string
      |> String.graphemes()
      |> Enum.at(0)
      |> Kernel.||("")

    String.downcase(str) != str
  end

  defp function_type(nil), do: nil

  defp function_type(type) do
    "data-fun-type=\"#{type}\""
  end

  defp function_href(contents, _libraries, nil, _, _, _), do: contents

  defp function_href(contents, _libraries, _, nil, _, _), do: contents

  defp function_href(contents, libraries, type, module_name, fun, arity) do
    case library_for(module_name, libraries) do
      nil ->
        contents

      library ->
        link =
          url(
            ~p'/docs/module/#{library.name}/latest/#{AshHqWeb.DocRoutes.sanitize_name(module_name)}'
          ) <>
            "##{type}-#{AshHqWeb.DocRoutes.sanitize_name(fun)}-#{arity}"

        ~s[<a href="#{link}">#{contents}</a>]
    end
  end

  defp module_href(contents, libraries, _type, module_name) do
    case library_for(module_name, libraries) do
      nil ->
        contents

      library ->
        link =
          url(
            ~p'/docs/module/#{library.name}/latest/#{AshHqWeb.DocRoutes.sanitize_name(module_name)}'
          )

        ~s[<a href="#{link}">#{contents}</a>]
    end
  end

  @doc false
  def library_for(module, libraries) do
    libraries
    |> Enum.map(fn library ->
      {library,
       Enum.find(library.module_prefixes, fn prefix ->
         prefix == module || String.starts_with?(module, prefix <> ".")
       end)}
    end)
    |> Enum.filter(fn
      {_library, nil} ->
        false

      _ ->
        true
    end)
    |> Enum.sort_by(fn {_library, match} ->
      -String.length(match)
    end)
    |> Enum.at(0)
    |> case do
      {library, _match} ->
        library

      _ ->
        nil
    end
  end

  defp render_code(lang, lexer, lexer_opts, code) do
    highlighted =
      code
      |> unescape_html()
      |> IO.iodata_to_binary()
      |> Makeup.highlight_inner_html(
        lexer: lexer,
        lexer_options: lexer_opts,
        formatter_options: [highlight_tag: "span"]
      )

    ~s(<code class="not-prose makeup #{lang} highlight">#{highlighted}</code>)
  rescue
    _ ->
      ~s(<code class="text-black dark:text-white">#{code}</code>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest), do: [unquote(decoded) | unescape_html(rest)]
  end

  defp unescape_html(<<c, rest::binary>>), do: [c | unescape_html(rest)]
  defp unescape_html(<<>>), do: []
end
