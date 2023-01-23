defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessor do
  @moduledoc """
  Takes a HTML document or a list of HTML documents, and runs a set of HTML
  post-processor transformations on them.
  """

  alias AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.{
    HeadingAutolinker,
    Highlighter,
    TableOfContentsGenerator
  }

  alias AshHq.Docs.Extensions.RenderMarkdown.RawHTML

  def run(html, libraries, current_library, current_module, add_ids?, add_table_of_contents?)
      when is_list(html) do
    Enum.map(
      html,
      &run(&1, libraries, current_library, current_module, add_ids?, add_table_of_contents?)
    )
  end

  def run(html, libraries, current_library, current_module, add_ids?, add_table_of_contents?) do
    html
    |> Floki.parse_document!()
    |> HeadingAutolinker.autolink(add_ids?)
    |> TableOfContentsGenerator.generate(add_table_of_contents?)
    |> Highlighter.highlight(libraries, current_library, current_module)
    |> RawHTML.raw_html(pretty: true)
  end
end
