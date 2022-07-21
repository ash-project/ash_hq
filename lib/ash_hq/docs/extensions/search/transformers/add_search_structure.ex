defmodule AshHq.Docs.Extensions.Search.Transformers.AddSearchStructure do
  use Ash.Dsl.Transformer
  import Ash.Filter.TemplateHelpers
  require Ash.Query
  alias Ash.Dsl.Transformer

  def transform(resource, dsl_state) do
    config = %{
      resource: resource,
      name_attribute: AshHq.Docs.Extensions.Search.name_attribute(resource),
      doc_attribute: AshHq.Docs.Extensions.Search.doc_attribute(resource),
      library_version_attribute: AshHq.Docs.Extensions.Search.library_version_attribute(resource),
      table: AshPostgres.table(resource)
    }

    {:ok,
     dsl_state
     |> add_code_interface()
     |> add_search_action(config)
     |> add_search_headline_calculation(config)
     |> add_name_matches_calculation(config)
     |> add_matches_calculation(config)
     |> add_indexes(config)
     |> add_match_rank_calculation(config)}
  end

  defp add_indexes(dsl_state, config) do
    dsl_state
    |> add_full_text_index(config)
    |> add_trigram_index(config)
    |> add_name_index(config)
  end

  defp add_full_text_index(dsl_state, config) do
    if config.doc_attribute do
      Transformer.add_entity(
        dsl_state,
        [:postgres, :custom_statements],
        Transformer.build_entity!(
          AshPostgres.DataLayer,
          [:postgres, :custom_statements],
          :statement,
          name: :search_index,
          up: """
          CREATE INDEX #{config.table}_search_index ON #{config.table} USING GIN((
            setweight(to_tsvector('english', #{config.name_attribute}), 'A') ||
            setweight(to_tsvector('english', #{config.doc_attribute}), 'D')
          ));
          """,
          down: "DROP INDEX #{config.table}_search_index;"
        )
      )
    else
      Transformer.add_entity(
        dsl_state,
        [:postgres, :custom_statements],
        Transformer.build_entity!(
          AshPostgres.DataLayer,
          [:postgres, :custom_statements],
          :statement,
          name: :search_index,
          up: """
          CREATE INDEX #{config.table}_search_index ON #{config.table} USING GIN((
            to_tsvector('english', #{config.name_attribute})
          ));
          """,
          down: "DROP INDEX #{config.table}_search_index;"
        )
      )
    end
  end

  defp add_trigram_index(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:postgres, :custom_statements],
      Transformer.build_entity!(
        AshPostgres.DataLayer,
        [:postgres, :custom_statements],
        :statement,
        name: :trigram_index,
        up: """
        CREATE INDEX #{config.table}_name_trigram_index ON #{config.table} USING GIST (#{config.name_attribute} gist_trgm_ops);
        """,
        down: "DROP INDEX #{config.table}_name_trigram_index;"
      )
    )
  end

  defp add_name_index(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:postgres, :custom_statements],
      Transformer.build_entity!(
        AshPostgres.DataLayer,
        [:postgres, :custom_statements],
        :statement,
        name: :name_index,
        up: """
        CREATE INDEX #{config.table}_name_lower_index ON #{config.table}(lower(#{config.name_attribute}));
        """,
        down: "DROP INDEX #{config.table}_name_lower_index;"
      )
    )
  end

  defp add_match_rank_calculation(dsl_state, config) do
    if config.doc_attribute do
      dsl_state
      |> Transformer.add_entity(
        [:calculations],
        Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
          name: :match_rank,
          type: :float,
          arguments: [query_argument()],
          calculation:
            Ash.Query.expr(
              fragment(
                "ts_rank(setweight(to_tsvector('english', ?), 'A') || setweight(to_tsvector('english', ?), 'D'), plainto_tsquery(?))",
                ^ref(config.name_attribute),
                ^ref(config.doc_attribute),
                ^arg(:query)
              )
            )
        )
      )
    else
      dsl_state
      |> Transformer.add_entity(
        [:calculations],
        Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
          name: :match_rank,
          type: :float,
          arguments: [query_argument()],
          calculation:
            Ash.Query.expr(
              fragment(
                "ts_rank(to_tsvector('english', ?), plainto_tsquery(?))",
                ^ref(config.name_attribute),
                ^arg(:query)
              )
            )
        )
      )
    end
  end

  defp add_matches_calculation(dsl_state, config) do
    if config.doc_attribute do
      Transformer.add_entity(
        dsl_state,
        [:calculations],
        Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
          name: :matches,
          type: :boolean,
          arguments: [query_argument()],
          calculation:
            Ash.Query.expr(
              name_matches(query: arg(:query), similarity: 0.8) or
                fragment(
                  "to_tsvector('english', ? || ?) @@ plainto_tsquery(?)",
                  ^ref(config.name_attribute),
                  ^ref(config.doc_attribute),
                  ^arg(:query)
                )
            )
        )
      )
    else
      Transformer.add_entity(
        dsl_state,
        [:calculations],
        Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
          name: :matches,
          type: :boolean,
          arguments: [query_argument()],
          calculation:
            Ash.Query.expr(
              name_matches(query: arg(:query), similarity: 0.8) or
                fragment(
                  "to_tsvector('english', ?) @@ plainto_tsquery(?)",
                  ^ref(config.name_attribute),
                  ^arg(:query)
                )
            )
        )
      )
    end
  end

  defp add_name_matches_calculation(dsl_state, config) do
    Transformer.add_entity(
      dsl_state,
      [:calculations],
      Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
        name: :name_matches,
        type: :boolean,
        arguments: [query_argument(), similarity_argument()],
        calculation:
          Ash.Query.expr(
            contains(
              fragment("lower(?)", ^ref(config.name_attribute)),
              fragment("lower(?)", ^arg(:query))
            ) or
              trigram_similarity(^ref(config.name_attribute), ^arg(:query)) >= ^arg(:similarity)
          )
      )
    )
  end

  defp add_search_headline_calculation(dsl_state, config) do
    if config.doc_attribute do
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
                "ts_headline('english', ?, plainto_tsquery('english', ?), 'MaxFragments=2,StartSel=\"<span class=\"\"search-hit\"\">\", StopSel=</span>')",
                ^ref(config.doc_attribute),
                ^arg(:query)
              )
            )
        )
      )
    else
      Transformer.add_entity(
        dsl_state,
        [:calculations],
        Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
          name: :search_headline,
          type: :string,
          arguments: [query_argument()],
          calculation: Ash.Query.expr("")
        )
      )
    end
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

  defp similarity_argument() do
    Transformer.build_entity!(
      Ash.Resource.Dsl,
      [:calculations, :calculate],
      :argument,
      type: :float,
      name: :similarity,
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
        preparation: AshHq.Extensions.Search.Preparations.LoadSearchData
      )
    ]
  end

  def before?(Ash.Resource.Transformers.SetTypes), do: true
  def before?(_), do: false
  def after?(Ash.Resource.Transformers.SetPrimaryActions), do: true
  def after?(_), do: false
end
