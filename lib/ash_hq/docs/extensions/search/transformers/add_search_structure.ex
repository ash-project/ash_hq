defmodule AshHq.Docs.Extensions.Search.Transformers.AddSearchStructure do
  @moduledoc """
  Adds the resource structure required by the search extension.

  * Adds a sanitized name attribute if it doesn't already exist
  * Adds a change to set the sanitized name, if it should.
  """
  use Spark.Dsl.Transformer
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
      sanitized_name_attribute: sanitized_name_attribute
    }

    {:ok, add_sanitized_name(dsl_state, config)}
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

  def before?(Ash.Resource.Transformers.SetTypes), do: true
  def before?(_), do: false
  def after?(Ash.Resource.Transformers.SetPrimaryActions), do: true
  def after?(Ash.Resource.Transformers.BelongsToAttribute), do: true
  def after?(_), do: false
end
