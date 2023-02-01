defmodule AshHq.Docs.Extensions.Search.Preparations.DeselectSearchable do
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    Ash.Query.deselect(query, [:searchable])
  end
end
