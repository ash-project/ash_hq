defmodule AshHq.Docs.Search.Steps.SearchResource do
  @moduledoc """
  Runs the search action of a given resource, or skips it if it should not be included in the results.
  """
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    resource = input[:resource]
    types = input[:types]
    library_versions = input[:library_versions]
    query = input[:query]

    if is_nil(types) || AshHq.Docs.Extensions.Search.type(resource) in types do
      query =
        resource
        |> Ash.Query.for_read(:search, %{
          library_versions: library_versions,
          query: query
        })

      query.resource
      |> AshHq.Docs.Extensions.RenderMarkdown.render_attributes()
      |> Enum.reduce(query, fn {source, target}, query ->
        Ash.Query.deselect(query, [source, target])
      end)
      |> AshHq.Docs.read()
    else
      {:ok, []}
    end
  end
end
