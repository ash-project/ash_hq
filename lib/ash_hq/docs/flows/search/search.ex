defmodule AshHq.Docs.Search do
  @moduledoc false

  @search [
    AshHq.Docs.Option,
    AshHq.Docs.MixTask,
    AshHq.Docs.Module,
    AshHq.Docs.Function,
    AshHq.Docs.Extension,
    AshHq.Docs.LibraryVersion,
    AshHq.Docs.Guide,
    AshHq.Docs.Dsl
  ]

  use Ash.Flow, otp_app: :ash_hq

  flow do
    api AshHq.Docs

    description """
    Runs a search over all searchable items.
    """

    argument :query, :string do
      allow_nil? false
      constraints trim?: false, allow_empty?: true
    end

    argument :library_versions, {:array, :uuid} do
      allow_nil? false
    end

    argument :types, {:array, :string}

    returns :build_results
  end

  steps do
    map :search_results, @search do
      custom :should_search, AshHq.Docs.Search.Steps.ShouldSearch do
        input %{
          resource: element(:search_results),
          types: arg(:types)
        }
      end

      branch :maybe_search, result(:should_search) do
        output :search

        read :search, element(:search_results), :search do
          input %{
            library_versions: arg(:library_versions),
            query: arg(:query)
          }
        end
      end
    end

    custom :build_results, AshHq.Docs.Search.Steps.BuildResults do
      input %{
        results: result(:search_results),
        query: arg(:query)
      }
    end
  end
end
