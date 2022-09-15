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

  def render!(%resource{} = record, key, on_demand? \\ false) do
    cond do
      render_attributes(resource)[key] ->
        Map.get(record, render_attributes(resource)[key])

      on_demand? ->
        case Map.get(record, key) do
          value when is_list(value) ->
            Enum.map(value, fn value ->
              as_html!(value || "", header_ids?(resource))
            end)

          value ->
            as_html!(value || "", header_ids?(resource))
        end

      true ->
        raise "#{resource} dos not render #{key} as markdown. Pass the `on_demand?` argument as `true` to render it dynamically."
    end
  end

  def as_html!(text, add_ids? \\ true)

  def as_html!(nil, _) do
    ""
  end

  def as_html!(%Ash.NotLoaded{}, _) do
    ""
  end

  def as_html!(text, add_ids?) when is_list(text) do
    Enum.map(text, &as_html!(&1, add_ids?))
  end

  def as_html!(text, add_ids?) do
    text
    |> Earmark.as_html!(opts(add_ids?))
    |> AshHq.Docs.Extensions.RenderMarkdown.Highlighter.highlight()
  end

  def as_html(text, add_ids?) when is_list(text) do
    Enum.reduce_while(text, {:ok, [], []}, fn text, {:ok, list, errors} ->
      case as_html(text, add_ids?) do
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

  def as_html(text, add_ids?) do
    text
    |> Earmark.as_html(opts(add_ids?))
    |> case do
      {:ok, html_doc, errors} ->
        {:ok, AshHq.Docs.Extensions.RenderMarkdown.Highlighter.highlight(html_doc), errors}

      {:error, html_doc, errors} ->
        {:error, html_doc, errors}
    end
  end

  defp opts(true) do
    [postprocessor: &add_ids/1]
  end

  defp opts(_) do
    []
  end

  defp add_ids({tag, attrs, [contents], meta} = node)
       when tag in ["h1", "h2", "h3", "h4", "h5", "h6"] and is_binary(contents) do
    if meta[:handled] do
      node
    else
      new_attrs = Enum.reject(attrs, fn {key, _} -> key == "id" end)

      id = String.downcase(String.replace(contents, ~r/[^A-Za-z0-9_]/, "-"))
      new_attrs = [{"id", id} | new_attrs]

      {"div", [{"class", "flex flex-row items-baseline"}],
       [
         {"a", [{"href", "##{id}"}],
          [
            {"svg",
             [
               {"xmlns", "http://www.w3.org/2000/svg"},
               {"class", "h-6 w-6"},
               {"fill", "none"},
               {"viewBox", "0 0 24 24"},
               {"stroke", "currentColor"},
               {"stroke-width", "2"}
             ],
             [
               {"path",
                [
                  {"stroke-linecap", "round"},
                  {"stroke-linejoin", "round"},
                  {"d",
                   "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"}
                ], [], %{}}
             ], %{}}
          ], %{}},
         {tag, new_attrs, [contents], %{handled: true}}
       ], %{}}
    end
  end

  defp add_ids(other), do: other
end
