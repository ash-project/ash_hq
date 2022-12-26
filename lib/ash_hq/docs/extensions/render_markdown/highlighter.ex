defmodule AshHq.Docs.Extensions.RenderMarkdown.Highlighter do
  @moduledoc false
  # Copied *directly* from nimble_publisher
  # https://github.com/dashbitco/nimble_publisher/blob/v0.1.2/lib/nimble_publisher/highlighter.ex

  @doc """
  Highlights all code block in an already generated HTML document.
  """
  def highlight(html) when is_list(html) do
    Enum.map(html, &highlight/1)
  end

  def highlight(html) do
    html
    |> Floki.parse_document!()
    |> Floki.traverse_and_update(fn
      {"pre", _, [{"code", attrs, [body]}]} when is_binary(body) ->
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
              {:keep, maybe_highlight_module(body)}
            else
              {:keep,
               ~s(<pre class="code-pre"><code class="text-black dark:text-white">#{body}</code></pre>)}
            end
        end

      other ->
        other
    end)
    |> AshHq.Docs.Extensions.RenderMarkdown.RawHTML.raw_html(pretty: true)
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

  defp replace_regex(string, regex, replacement) do
    Regex.replace(regex, string, replacement)
  end

  defp maybe_highlight_module(code) do
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

    try_parse_multi([
      {~s(data-fun-type="callback"), code_without_c},
      {~s(data-fun-type="type"), code_without_type},
      {nil, code}
    ])
  end

  defp try_parse_multi([{_, nil} | rest]), do: try_parse_multi(rest)

  defp try_parse_multi([{text, code} | rest]) do
    case Code.string_to_quoted(code) do
      {:ok, {fun, _, []}} when is_atom(fun) ->
        ~s[<code #{text} class="inline maybe-local-call text-black dark:text-white" data-fun="#{fun}">#{code}</code>]

      {:ok,
       {:/, _,
        [
          {{:., _, [{:__aliases__, _, parts}, fun]}, _, []},
          arity
        ]}}
      when is_atom(fun) and is_integer(arity) ->
        ~s[<code #{text} class="inline maybe-call text-black dark:text-white" data-module="#{Enum.join(parts, ".")}" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>]

      {:ok, {:/, _, [{fun, _, nil}, arity]}} when is_atom(fun) and is_integer(arity) ->
        ~s[<code #{text} class="inline maybe-local-call text-black dark:text-white" data-fun="#{fun}" data-arity="#{arity}">#{code}</code>]

      {:ok, {:__aliases__, _, parts}} ->
        ~s[<code #{text} class="inline maybe-module text-black dark:text-white" data-module="#{Enum.join(parts, ".")}">#{code}</code>]

      _ ->
        if rest == [] do
          ~s[<code class="inline text-black dark:text-white">#{code}</code>]
        else
          try_parse_multi(rest)
        end
    end
  rescue
    _ ->
      ~s[<code class="inline">#{code}</code>]
  end

  defp highlight_code_block(_full_block, lang, code) do
    case pick_language_and_lexer(lang) do
      {language, lexer, opts} -> render_code(language, lexer, opts, code)
    end
  end

  defp pick_language_and_lexer(""), do: {"text", nil, []}

  defp pick_language_and_lexer(lang) do
    case Makeup.Registry.fetch_lexer_by_name(lang) do
      {:ok, {lexer, opts}} -> {lang, lexer, opts}
      :error -> {lang, nil, []}
    end
  end

  defp render_code(lang, lexer, lexer_opts, code) do
    highlighted =
      code
      # |> unescape_html()
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

    ~s(<pre class="code-pre"><code class="makeup #{lang} highlight">#{highlighted}</code></pre>)
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest), do: [unquote(decoded) | unescape_html(rest)]
  end

  defp unescape_html(<<c, rest::binary>>), do: [c | unescape_html(rest)]
  defp unescape_html(<<>>), do: []
end
