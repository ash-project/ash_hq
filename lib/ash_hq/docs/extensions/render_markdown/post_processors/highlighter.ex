defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.Highlighter do
  @moduledoc false
  # Highlights fenced code blocks with Makeup, styled by `assets/css/syntax.css`.

  def highlight(ast, _libraries, _current_library, _current_module) do
    Floki.traverse_and_update(ast, fn
      {"pre", _, [{"code", attrs, [body]}]} = pre when is_binary(body) ->
        case lexer(attrs) do
          {lexer, opts} ->
            code = Makeup.highlight_inner_html(body, lexer: lexer, lexer_options: opts)
            {:keep, ~s(<pre class="highlight"><code>#{code}</code></pre>)}

          nil ->
            pre
        end

      other ->
        other
    end)
  end

  defp lexer(attrs) do
    with {"class", classes} <- List.keyfind(attrs, "class", 0),
         "language-" <> language <-
           classes |> String.split() |> Enum.find(&String.starts_with?(&1, "language-")),
         {:ok, lexer} <- Makeup.Registry.fetch_lexer_by_name(language) do
      lexer
    else
      _ -> nil
    end
  end
end
