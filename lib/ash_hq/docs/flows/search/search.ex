defmodule AshHq.Docs.Search do
  use Ash.Flow

  flow do
    api AshHq.Docs

    argument :query, :string do
      allow_nil? false
    end

    argument :library_versions, {:array, :uuid} do
      allow_nil? false
    end

    returns :build_results
  end

  steps do
    read :options, AshHq.Docs.Option, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    read :dsls, AshHq.Docs.Dsl, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    read :guides, AshHq.Docs.Guide, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    read :library_versions, AshHq.Docs.LibraryVersion, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    read :extensions, AshHq.Docs.Extension, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    read :functions, AshHq.Docs.Function, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    read :modules, AshHq.Docs.Module, :search do
      input %{
        library_versions: arg(:library_versions),
        query: arg(:query)
      }
    end

    custom :build_results, AshHq.Docs.Search.Steps.BuildResults do
      input %{
        dsls: result(:dsls),
        options: result(:options),
        guides: result(:guides),
        library_versions: result(:library_versions),
        extensions: result(:extensions),
        functions: result(:functions),
        modules: result(:modules)
      }
    end
  end
end
