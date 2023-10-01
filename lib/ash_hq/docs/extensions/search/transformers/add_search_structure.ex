defmodule AshHq.Docs.Extensions.Search.Transformers.AddSearchStructure do
  @moduledoc """
  Adds the resource structure required by the search extension.

  * Adds a sanitized name attribute if it doesn't already exist
  * Adds a change to set the sanitized name, if it should.
  * Adds a `search_headline` calculation
  * Adds a `matches` calculation
  * Adds relevant indexes using custom sql statements
  * Adds a `match_rank` calculation.
  * Adds a search action
  * Adds a code interface for the search action
  """
  use Spark.Dsl.Transformer
  import Ash.Filter.TemplateHelpers
  require Ash.Query
  alias Spark.Dsl.Transformer

  # sobelow_skip ["DOS.BinToAtom"]
  def transform(dsl_state) do
    name_attribute = Transformer.get_option(dsl_state, [:search], :name_attribute) || :name

    sanitized_name_attribute =
      Transformer.get_option(dsl_state, [:search], :sanitized_name_attribute) ||
        :"sanitized_#{name_attribute}"

    config = %{
      name_attribute: name_attribute,
      doc_attribute: Transformer.get_option(dsl_state, [:search], :doc_attribute),
      library_version_attribute:
        Transformer.get_option(dsl_state, [:search], :library_version_attribute) ||
          :library_version_id,
      table: Transformer.get_option(dsl_state, [:postgres], :table),
      sanitized_name_attribute: sanitized_name_attribute
    }

    currently_ignored_attributes =
      AshPostgres.DataLayer.Info.migration_ignore_attributes(dsl_state)

    dsl_state
    |> add_sanitized_name(config)
    |> add_search_action(config)
    |> add_code_interface()
    |> Transformer.set_option([:postgres], :migration_ignore_attributes, [
      :searchable | currently_ignored_attributes
    ])
    |> add_search_headline_calculation(config)
    |> add_matches_calculation()
    |> add_full_text_column(config)
    |> add_full_text_index()
    |> add_match_rank_calculation(config)
    |> Ash.Resource.Builder.add_preparation(
      {AshHq.Docs.Extensions.Search.Preparations.DeselectSearchable, []}
    )
    |> Ash.Resource.Builder.add_attribute(:searchable, AshHq.Docs.Search.Types.TsVector,
      generated?: true,
      private?: true
    )
  end

  defp add_sanitized_name(dsl_state, config) do
    dsl_state =
      cond do
        !Transformer.get_option(dsl_state, [:search], :has_name_attribute?, true) ->
          dsl_state

        Enum.find(
          Transformer.get_entities(dsl_state, [:attributes]),
          &(&1.name == config.sanitized_name_attribute)
        ) ->
          dsl_state

        true ->
          Transformer.add_entity(
            dsl_state,
            [:attributes],
            Transformer.build_entity!(
              Ash.Resource.Dsl,
              [:attributes],
              :attribute,
              private?: true,
              name: config.sanitized_name_attribute,
              type: :string,
              allow_nil?: false
            )
          )
      end

    if Transformer.get_option(dsl_state, [:search], :has_name_attribute?, true) do
      Transformer.add_entity(
        dsl_state,
        [:changes],
        Transformer.build_entity!(Ash.Resource.Dsl, [:changes], :change,
          change:
            {AshHq.Docs.Extensions.Search.Changes.SanitizeName,
             source: config.name_attribute,
             destination: config.sanitized_name_attribute,
             add_name_to_path?: Transformer.get_option(dsl_state, [:search], :add_name_to_path?),
             use_path_for_name?: Transformer.get_option(dsl_state, [:search], :use_path_for_name?)}
        )
      )
    else
      dsl_state
    end
  end

  defp add_full_text_index(dsl_state) do
    Transformer.add_entity(
      dsl_state,
      [:postgres, :custom_indexes],
      Transformer.build_entity!(
        AshPostgres.DataLayer,
        [:postgres, :custom_indexes],
        :index,
        fields: [:searchable],
        using: "GIN"
      )
    )
  end

  defp add_full_text_column(dsl_state, config) do
    if config.doc_attribute do
      if Transformer.get_option(dsl_state, [:search], :has_name_attribute?, true) do
        Transformer.add_entity(
          dsl_state,
          [:postgres, :custom_statements],
          Transformer.build_entity!(
            AshPostgres.DataLayer,
            [:postgres, :custom_statements],
            :statement,
            name: :search_column,
            up: """
            ALTER TABLE #{config.table}
              ADD COLUMN searchable tsvector
              GENERATED ALWAYS AS (
                setweight(to_tsvector('english', #{config.name_attribute}), 'A') ||
                setweight(to_tsvector('english', #{config.doc_attribute}), 'D')
              ) STORED;
            """,
            down: """
            ALTER TABLE #{config.table}
              DROP COLUMN searchable
            """
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
            name: :search_column,
            up: """
            ALTER TABLE #{config.table}
              ADD COLUMN searchable tsvector
              GENERATED ALWAYS AS (
                setweight(to_tsvector('english', #{config.doc_attribute}), 'D')
              ) STORED;
            """,
            down: """
            ALTER TABLE #{config.table}
              DROP COLUMN searchable
            """
          )
        )
      end
    else
      Transformer.add_entity(
        dsl_state,
        [:postgres, :custom_statements],
        Transformer.build_entity!(
          AshPostgres.DataLayer,
          [:postgres, :custom_statements],
          :statement,
          name: :search_column,
          up: """
          ALTER TABLE #{config.table}
            ADD COLUMN searchable tsvector
            GENERATED ALWAYS AS (
              setweight(to_tsvector('english', #{config.name_attribute}), 'A')
            ) STORED;
          """,
          down: """
          ALTER TABLE #{config.table}
            DROP COLUMN searchable
          """
        )
      )
    end
  end

  defp add_match_rank_calculation(dsl_state, _config) do
    weight_content = AshHq.Docs.Extensions.Search.weight_content(dsl_state)

    dsl_state
    |> Transformer.add_entity(
      [:calculations],
      Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
        name: :match_rank,
        type: :float,
        private?: true,
        arguments: [query_argument()],
        calculation:
          Ash.Query.expr(
            fragment(
              "(ts_rank_cd('{0.05, 0.1, 0.1, 1.0}', ?, websearch_to_tsquery(?), 32) + ?)",
              ^ref(:searchable),
              ^arg(:query),
              ^weight_content
            )
          )
      )
    )
  end

  defp add_matches_calculation(dsl_state) do
    Transformer.add_entity(
      dsl_state,
      [:calculations],
      Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
        name: :matches,
        type: :boolean,
        private?: true,
        arguments: [query_argument()],
        calculation:
          Ash.Query.expr(
            fragment(
              "(? @@ websearch_to_tsquery(?))",
              ^ref(:searchable),
              ^arg(:query)
            )
          )
      )
    )
  end

  # defp add_name_matches_calculation(dsl_state, config) do
  #   if AshHq.Docs.Extensions.Search.has_name_attribute?(dsl_state) do
  #     Transformer.add_entity(
  #       dsl_state,
  #       [:calculations],
  #       Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
  #         name: :name_matches,
  #         type: :boolean,
  #         arguments: [query_argument(), similarity_argument()],
  #         private?: true,
  #         calculation:
  #           Ash.Query.expr(
  #             contains(
  #               fragment("lower(?)", ^ref(config.name_attribute)),
  #               fragment("lower(?)", ^arg(:query))
  #             )
  #           )
  #       )
  #     )
  #   else
  #     dsl_state
  #   end
  # end

  defp add_search_headline_calculation(dsl_state, config) do
    if config.doc_attribute do
      Transformer.add_entity(
        dsl_state,
        [:calculations],
        Transformer.build_entity!(Ash.Resource.Dsl, [:calculations], :calculate,
          name: :search_headline,
          type: :string,
          private?: true,
          arguments: [query_argument()],
          calculation:
            Ash.Query.expr(
              # credo:disable-for-next-line
              fragment(
                "ts_headline('english', ?, websearch_to_tsquery('english', ?), 'MaxFragments=2,StartSel=\"<span class=\"\"search-hit\"\">\", StopSel=</span>')",
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
          private?: true,
          calculation: Ash.Query.expr("")
        )
      )
    end
  end

  defp query_argument do
    Transformer.build_entity!(
      Ash.Resource.Dsl,
      [:calculations, :calculate],
      :argument,
      type: :string,
      name: :query,
      allow_nil?: false
    )
  end

  defp add_search_action(dsl_state, _config) do
    query_argument =
      Transformer.build_entity!(
        Ash.Resource.Dsl,
        [:actions, :read],
        :argument,
        type: :string,
        name: :query
      )

    {arguments, filter} =
      {[query_argument], Ash.Query.expr(matches(query: arg(:query)))}

    Transformer.add_entity(
      dsl_state,
      [:actions],
      Transformer.build_entity!(Ash.Resource.Dsl, [:actions], :read,
        name: :search,
        arguments: arguments,
        preparations: search_preparations(),
        filter: filter
      )
    )
  end

  defp add_code_interface(dsl_state) do
    Transformer.add_entity(
      dsl_state,
      [:code_interface],
      Transformer.build_entity!(Ash.Resource.Dsl, [:code_interface], :define,
        name: :search,
        args: [:query]
      )
    )
  end

  defp search_preparations do
    [
      Transformer.build_entity!(Ash.Resource.Dsl, [:actions, :read], :prepare,
        preparation: AshHq.Extensions.Search.Preparations.LoadSearchData
      )
    ]
  end

  def before?(Ash.Resource.Transformers.SetTypes), do: true
  def before?(_), do: false
  def after?(Ash.Resource.Transformers.SetPrimaryActions), do: true
  def after?(Ash.Resource.Transformers.BelongsToAttribute), do: true
  def after?(_), do: false
end
