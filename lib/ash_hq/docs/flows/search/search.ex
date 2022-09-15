defmodule AshHq.Docs.Search do
  @moduledoc false

  use Ash.Flow, otp_app: :ash_hq

  flow do
    api(AshHq.Docs)

    description("""
    Runs a search over all searchable items.
    """)

    argument :query, :string do
      allow_nil?(false)
      constraints(trim?: false, allow_empty?: true)
    end

    argument :library_versions, {:array, :uuid} do
      allow_nil?(false)
    end

    argument(:types, {:array, :string})

    returns(:build_results)
  end

  steps do
    custom :options, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.Option
      })
    end

    custom :dsls, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.Dsl
      })
    end

    custom :guides, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.Guide
      })
    end

    custom :library_versions, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.LibraryVersion
      })
    end

    custom :extensions, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.Extension
      })
    end

    custom :functions, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.Function
      })
    end

    custom :modules, AshHq.Docs.Search.Steps.SearchResource do
      input(%{
        query: arg(:query),
        library_versions: arg(:library_versions),
        types: arg(:types),
        resource: AshHq.Docs.Module
      })
    end

    custom :build_results, AshHq.Docs.Search.Steps.BuildResults do
      input(%{
        dsls: result(:dsls),
        options: result(:options),
        guides: result(:guides),
        library_versions: result(:library_versions),
        extensions: result(:extensions),
        functions: result(:functions),
        modules: result(:modules)
      })
    end
  end
end
