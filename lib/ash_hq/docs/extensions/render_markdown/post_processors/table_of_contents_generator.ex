defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.TableOfContentsGenerator do
  @moduledoc """
  Auto-generates a table of contents to be rendered as part of the HTML.
  This links H2s and H3s to their respective parts of the document
  """

  def generate(ast, false), do: ast

  def generate(ast, true) do
    case parse_headings(ast) do
      # No headings
      [] ->
        ast

      # Yes headings - we need to build the right AST nodes for them and then insert them into the AST
      headings ->
        [main_heading | rest] = ast
        [main_heading | generate_html(headings)] ++ rest
    end
  end

  defp generate_html(headings) do
    contents =
      Enum.map(headings, fn [h2 | h3s] ->
        {_tag, attrs, [text]} = h2
        text = Floki.text(text)
        {"id", id} = Enum.find(attrs, fn {k, _v} -> k == "id" end)

        {
          "li",
          [],
          [
            {
              "a",
              [
                {"href", "##{id}"},
                {"class", "text-primary-light-600 dark:text-primary-dark-400"}
              ],
              [String.trim(text)]
            }
            | generate_subheadings(h3s)
          ]
        }
      end)

    [
      {"div",
       [
         {"class",
          "float-right w-[20em] border border-base-light-300 border-base-dark-600 p-4 ml-8 mb-8"}
       ],
       [
         {"p", [{"class", "m-0 font-bold"}],
          [
            {"svg",
             [
               {"xmlns", "http://www.w3.org/2000/svg"},
               {"class", "inline-block h-5 w-5"},
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
                   "M16 4v12l-4-2-4 2V4M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"}
                ], []}
             ]},
            "Table of Contents"
          ]},
         {"ol", [], contents}
       ]}
    ]
  end

  defp generate_subheadings([]), do: []

  defp generate_subheadings(h3s) do
    contents =
      Enum.map(h3s, fn h3 ->
        {_tag, attrs, [text]} = h3

        text = Floki.text(text)
        {"id", id} = Enum.find(attrs, fn {k, _v} -> k == "id" end)

        {
          "li",
          [{"class", "my-0.5"}],
          [
            {
              "a",
              [
                {"href", "##{id}"},
                {"class",
                 "text-primary-light-600 dark:text-primary-dark-400 block text-ellipsis overflow-hidden"}
              ],
              [String.trim(text)]
            }
          ]
        }
      end)

    [{"ol", [{"class", "list-[lower-alpha] m-0"}], contents}]
  end

  defp parse_headings(ast) do
    ast
    |> Floki.traverse_and_update([], fn
      {tag, attrs, _contents} = heading, acc when tag in ["h2", "h3"] ->
        if Enum.find(attrs, fn {k, _v} -> k == "id" end) do
          {heading, [heading | acc]}
        else
          {heading, acc}
        end

      other, acc ->
        {other, acc}
    end)
    |> elem(1)
    |> Enum.reverse()
    |> chunk_by_level()
  end

  # Group the list of all headings into H2s and their child H3s
  defp chunk_by_level(list) do
    list
    |> Enum.chunk_while(
      [],
      fn element, acc ->
        if elem(element, 0) == "h2" do
          {:cont, Enum.reverse(acc), [element]}
        else
          {:cont, [element | acc]}
        end
      end,
      fn rest -> {:cont, Enum.reverse(rest), []} end
    )
    |> tl()
  end
end
