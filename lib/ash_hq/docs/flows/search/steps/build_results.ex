defmodule AshHq.Docs.Search.Steps.BuildResults do
  @moduledoc """
  Sorts the results of search.
  """
  use Ash.Flow.Step

  def run(input, _opts, _context) do
    {:ok,
     input[:results]
     |> Kernel.||([])
     |> List.flatten()
     |> Enum.reject(&is_nil/1)
     |> Enum.sort_by(&(-&1.match_rank))}
  end
end
