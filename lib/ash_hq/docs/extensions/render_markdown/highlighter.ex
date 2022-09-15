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
    Regex.replace(
      ~r/<pre><code(?:\s+class="(\w*)")?>([^<]*)<\/code><\/pre>/,
      html,
      &highlight_code_block(&1, &2, &3)
    )
  end

  defp highlight_code_block(full_block, lang, code) do
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
    if lexer do
      highlighted =
        code
        |> unescape_html()
        |> IO.iodata_to_binary()
        |> Makeup.highlight_inner_html(
          lexer: lexer,
          lexer_options: lexer_opts,
          formatter_options: [highlight_tag: "span"]
        )

      ~s(<pre class="code-pre"><code class="makeup #{lang} highlight">#{highlighted}</code></pre>)
    else
      ~s(<pre class="code-pre"><code class="makeup #{lang} text-black dark:text-white">#{code}</code></pre>)
    end
  end

  entities = [{"&amp;", ?&}, {"&lt;", ?<}, {"&gt;", ?>}, {"&quot;", ?"}, {"&#39;", ?'}]

  for {encoded, decoded} <- entities do
    defp unescape_html(unquote(encoded) <> rest), do: [unquote(decoded) | unescape_html(rest)]
  end

  defp unescape_html(<<c, rest::binary>>), do: [c | unescape_html(rest)]
  defp unescape_html(<<>>), do: []
end
