defmodule AshHq.Docs.Search.Steps.ShouldSearch do
  @moduledoc """
  Determines if the type of the resource is in the types being searched
  """
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    resource = input[:resource]
    types = input[:types]

    {:ok, is_nil(types) || AshHq.Docs.Extensions.Search.type(resource) in types}
  end
end
