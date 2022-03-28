defmodule AshHq.Docs.Extensions.RenderMarkdown do
  @render_markdown %Ash.Dsl.Section{
    name: :render_markdown,
    schema: [
      render_attributes: [
        type: :keyword_list,
        default: [],
        doc:
          "A keyword list of attributes that should have markdown rendered as html, and the attribute that should be written to."
      ]
    ]
  }

  use Ash.Dsl.Extension,
    sections: [@render_markdown],
    transformers: [AshHq.Docs.Extensions.RenderMarkdown.Transformers.AddRenderMarkdownStructure]

  def attributes(resource) do
    Ash.Dsl.Extension.get_opt(resource, [:render_markdown], :attributes, [])
  end

  def render!(%resource{} = record, key, on_demand? \\ false) do
    cond do
      attributes(resource)[key] ->
        Map.get(record, attributes(resource)[key])

      on_demand? ->
        Earmark.as_html!(Map.get(record, key) || "")

      true ->
        raise "#{resource} dos not render #{key} as markdown. Pass the `on_demand?` argument as `true` to render it dynamically."
    end
  end
end
