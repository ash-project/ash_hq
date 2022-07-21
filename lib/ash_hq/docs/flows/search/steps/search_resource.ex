defmodule AshHq.Docs.Search.Steps.SearchResource do
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    resource = input[:resource]
    types = input[:types]
    library_versions = input[:library_versions]
    query = input[:query]

    if is_nil(types) || AshHq.Docs.Extensions.Search.type(resource) in types do
      resource
      |> Ash.Query.for_read(:search, %{
        library_versions: library_versions,
        query: query
      })
      |> AshHq.Docs.read()
    else
      {:ok, []}
    end
  end
end
