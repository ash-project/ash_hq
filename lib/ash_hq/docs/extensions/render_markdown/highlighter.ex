defmodule AshHq.Docs.Extensions.RenderMarkdown.Highlighter do
  @moduledoc false
  # Copied *directly* from nimble_publisher
  # https://github.com/dashbitco/nimble_publisher/blob/v0.1.2/lib/nimble_publisher/highlighter.ex

  use AshHqWeb, :verified_routes

  @doc """
  Highlights all code block in an already generated HTML document.
  """
  def highlight(html, libraries, current_library, current_module) when is_list(html) do
    Enum.map(html, &highlight(&1, libraries, current_library, current_module))
  end

  def highlight(html, libraries, current_library, current_module) do
    html
    |> Floki.parse_document!()
    |> Floki.traverse_and_update(fn
      {"a", attrs, contents} ->
        {"a", rewrite_href_attr(attrs, current_library, libraries), contents}

      {"code", attrs, [body]} when is_binary(body) ->
        lexer =
          find_value_class(attrs, fn class ->
            case Makeup.Registry.fetch_lexer_by_name(class) do
              {:ok, {lexer, opts}} -> {class, lexer, opts}
              :error -> nil
            end
          end)

        case lexer do
          {lang, lexer, opts} ->
            {:keep, render_code(lang, lexer, opts, body)}

          nil ->
            if find_value_class(attrs, &(&1 == "inline")) do
              {:keep, maybe_highlight_module(body, libraries, current_module)}
            else
              {:keep, ~s(<code class="text-black dark:text-white">#{body}</code>)}
            end
        end

      other ->
        other
    end)
    |> AshHq.Docs.Extensions.RenderMarkdown.RawHTML.raw_html(pretty: true)
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

    case {uri, Path.split(String.trim_leading(uri.path || "", "/"))} |> IO.inspect() do
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

        dsl_dots = Enum.join(dsl_path, ".")
        dsl_path = Enum.join(dsl_path, "/")

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

  defp library_for(module, libraries) do
    Enum.find(libraries, fn library ->
      Enum.any?(library.module_prefixes, &String.starts_with?(module, &1 <> "."))
    end)
  end

  defp render_code(lang, lexer, lexer_opts, code) do
    highlighted =
      code
      |> unescape_html()
      |> IO.iodata_to_binary()
      |> String.replace(~r/{{mix_dep:.*}}/, fn value ->
        try do
          "{{mix_dep:" <> dep = String.trim_trailing(value, "}}")
          "______#{dep}______"
        rescue
          _ ->
            value
        end
      end)
      |> Makeup.highlight_inner_html(
        lexer: lexer,
        lexer_options: lexer_opts,
        formatter_options: [highlight_tag: "span"]
      )
      |> String.replace(~r/______.*______/, fn dep ->
        value =
          dep
          |> String.trim_leading("_")
          |> String.trim_trailing("_")

        "{{mix_dep:#{value}}}"
      end)

    ~s(<code class="makeup #{lang} highlight">#{highlighted}</code>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest), do: [unquote(decoded) | unescape_html(rest)]
  end

  defp unescape_html(<<c, rest::binary>>), do: [c | unescape_html(rest)]
  defp unescape_html(<<>>), do: []
end
