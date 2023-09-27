defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.Highlighter do
  @moduledoc false
  # Copied *directly* from nimble_publisher
  # https://github.com/dashbitco/nimble_publisher/blob/v0.1.2/lib/nimble_publisher/highlighter.ex

  use AshHqWeb, :verified_routes

  def highlight(ast, libraries, current_library, _current_module) do
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
              ~s(<code class="text-black dark:text-white">#{body}</code>)
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
              ~s(<code class="text-black dark:text-white">#{body}</code>)
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
      {%{host: "hexdocs.pm"}, _} ->
          value

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
