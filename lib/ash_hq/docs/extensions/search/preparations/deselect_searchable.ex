defmodule AshHq.Docs.Extensions.Search.Preparations.DeselectSearchable do
  @moduledoc "Deselects the searchable attribute"
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    Ash.Query.deselect(query, [:searchable])
  end
end
