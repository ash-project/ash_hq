defmodule AshHq.Docs.Extensions.RenderMarkdown do
  @moduledoc """
  Sets up markdown text attributes to be transformed to html (in another column).
  """

  @render_markdown %Spark.Dsl.Section{
    name: :render_markdown,
    schema: [
      render_attributes: [
        type: :keyword_list,
        default: [],
        doc:
          "A keyword list of attributes that should have markdown rendered as html, and the attribute that should be written to."
      ],
      header_ids?: [
        type: :boolean,
        default: true,
        doc: "Set to false to disable setting an id for each header."
      ],
      table_of_contents?: [
        type: :boolean,
        default: false,
        doc: "Set to true to enable a table of contents to be generated."
      ]
    ]
  }

  use Spark.Dsl.Extension,
    sections: [@render_markdown],
    transformers: [AshHq.Docs.Extensions.RenderMarkdown.Transformers.AddRenderMarkdownStructure]

  def render_attributes(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:render_markdown], :render_attributes, [])
  end

  def header_ids?(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:render_markdown], :header_ids?, [])
  end

  def table_of_contents?(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:render_markdown], :table_of_contents?, [])
  end

  def as_html(text, libraries, current_module, add_ids?, add_table_of_contents?)
      when is_list(text) do
    Enum.reduce_while(text, {:ok, [], []}, fn text, {:ok, list, errors} ->
      case as_html(text, libraries, current_module, add_ids?, add_table_of_contents?) do
        {:ok, text, new_errors} ->
          {:cont, {:ok, [text | list], errors ++ new_errors}}

        other ->
          {:halt, other}
      end
    end)
    |> case do
      {:ok, list, errors} ->
        {:ok, Enum.reverse(list), errors}

      other ->
        other
    end
  end

  def as_html(nil, _, _, _, _, _) do
    {:ok, nil, []}
  end

  def as_html(text, libraries, current_library, current_module, add_ids?, add_table_of_contents?) do
    text
    |> Earmark.as_html()
    |> case do
      {:ok, html_doc, errors} ->
        processed_html =
          AshHq.Docs.Extensions.RenderMarkdown.PostProcessor.run(
            html_doc,
            libraries,
            current_library,
            current_module,
            add_ids?,
            add_table_of_contents?
          )

        {:ok, processed_html, errors}

      {:error, html_doc, errors} ->
        {:error, html_doc, errors}
    end
  end
end
