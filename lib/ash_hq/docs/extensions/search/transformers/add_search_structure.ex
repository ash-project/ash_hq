defmodule AshHq.Docs.Extensions.Search.Transformers.AddSearchStructure do
  use Ash.Dsl.Transformer
  import Ash.Filter.TemplateHelpers
  require Ash.Query
  alias Ash.Dsl.Transformer

  def transform(resource, dsl_state) do
    config = %{
      name_attribute: AshHq.Docs.Extensions.Search.name_attribute(resource),
      doc_attribute: AshHq.Docs.Extensions.Search.doc_attribute(resource),
      library_version_attribute: AshHq.Docs.Extensions.Search.library_version_attribute(resource)
    }

    {:ok,
     dsl_state
     |> add_code_interface()
     |> add_search_action(config)
     |> add_search_headline_calculation(config)
     |> add_matches_calculation(config)
     |> add_match_rank_calculation(config)}
  end

  defp add_match_rank_calculation(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:calculations],
      Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
        name: :match_rank,
        type: :float,
        arguments: [query_argument()],
        calculation:
          Ash.Query.expr(
            fragment(
              "ts_rank(setweight(to_tsvector(?), 'A') || setweight(to_tsvector(?), 'D'), plainto_tsquery(?))",
              ^ref(config.name_attribute),
              ^ref(config.doc_attribute),
              ^arg(:query)
            )
          )
      )
    )
  end

  defp add_matches_calculation(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:calculations],
      Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
        name: :matches,
        type: :boolean,
        arguments: [query_argument()],
        calculation:
          Ash.Query.expr(
            contains(type(^ref(config.name_attribute), ^Ash.Type.CiString), ^arg(:query)) or
              trigram_similarity(^ref(config.name_attribute), ^arg(:query)) >= 0.3 or
              fragment(
                "to_tsvector(? || ?) @@ plainto_tsquery(?)",
                ^ref(config.name_attribute),
                ^ref(config.doc_attribute),
                ^arg(:query)
              )
          )
      )
    )
  end

  defp add_search_headline_calculation(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:calculations],
      Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
        name: :search_headline,
        type: :string,
        arguments: [query_argument()],
        calculation:
          Ash.Query.expr(
            fragment(
              "ts_headline('english', ?, plainto_tsquery('english', ?), 'MaxFragments=3,StartSel=\"<span class=\"\"search-hit\"\">\", StopSel=</span>')",
              ^ref(config.doc_attribute),
              ^arg(:query)
            )
          )
      )
    )
  end

  defp query_argument() do
    Transformer.build_entity!(
      Ash.Resource.Dsl,
      [:calculations, :calculate],
      :argument,
      type: :string,
      name: :query,
      allow_nil?: false
    )
  end

  defp add_search_action(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:actions],
      Transformer.build_entity!(Ash.Resource.Dsl, [:actions], :read,
        name: :search,
        arguments: search_arguments(),
        preparations: search_preparations(),
        filter:
          Ash.Query.expr(
            matches(query: arg(:query)) and
              ^ref(config.library_version_attribute) in ^arg(:library_versions)
          )
      )
    )
  end

  defp add_code_interface(dsl_state) do
    Transformer.add_entity(
      dsl_state,
      [:code_interface],
      Transformer.build_entity!(Ash.Resource.Dsl, [:code_interface], :define,
        name: :search,
        args: [:query, :library_versions]
      )
    )
  end

  defp search_arguments() do
    [
      Transformer.build_entity!(
        Ash.Resource.Dsl,
        [:actions, :read],
        :argument,
        type: {:array, :uuid},
        name: :library_versions
      ),
      Transformer.build_entity!(
        Ash.Resource.Dsl,
        [:actions, :read],
        :argument,
        type: :string,
        name: :query
      )
    ]
  end

  defp search_preparations() do
    [
      Transformer.build_entity!(Ash.Resource.Dsl, [:actions, :read], :prepare,
        preparation: AshHq.Docs.Preparations.LoadSearchData
      )
    ]
  end

  def before?(Ash.Resource.Transformers.SetTypes), do: true
  def before?(_), do: false
  def after?(Ash.Resource.Transformers.SetPrimaryActions), do: true
  def after?(_), do: false
end
