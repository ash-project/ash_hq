defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.HeadingAutolinker do
  @moduledoc false

  def autolink(ast, false), do: ast

  def autolink(ast, true) do
    ast
    |> Floki.traverse_and_update(fn
      {tag, attrs, [contents]}
      when tag in ["h1", "h2", "h3", "h4", "h5", "h6"] and is_binary(contents) ->
        new_attrs = Enum.reject(attrs, fn {key, _} -> key == "id" end)

        id = to_hash(contents)
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
                  ], []}
               ]}
            ]},
           {tag, new_attrs, [contents]}
         ]}

      other ->
        other
    end)
  end

  def to_hash(contents) do
    contents
    |> String.trim()
    |> String.replace(~r/[^A-Za-z0-9_]/, "-")
    |> String.downcase()
  end
end
