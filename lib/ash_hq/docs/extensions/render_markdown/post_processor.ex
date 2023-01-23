defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessor do
  @moduledoc """
  Takes a HTML document or a list of HTML documents, and runs a set of HTML
  post-processor transformations on them.
  """

  def run(html, libraries, current_library, current_module) when is_list(html) do
    Enum.map(html, &run(&1, libraries, current_library, current_module))
  end

  def run(html, libraries, current_library, current_module) do
    html
    |> Floki.parse_document!()
    |> AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.Highlighter.highlight(
      libraries,
      current_library,
      current_module
    )
    |> AshHq.Docs.Extensions.RenderMarkdown.RawHTML.raw_html(pretty: true)
  end
end
