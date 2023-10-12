defmodule AshHq.Docs.Extensions.Search do
  @moduledoc """
  Sets a resource up to be searchable. See the configuration for explanation of the options.

  This generally involves ensuring that there is a url safe name attribute to be used in routing,
  and configuring how the item will be searched for.
  """
  alias Spark.Dsl.Extension

  @search %Spark.Dsl.Section{
    name: :search,
    schema: [
      type: [
        type: :string,
        default: "DSL",
        doc: "The type of item. Used to narrow down search results, displayed in the UI."
      ],
      item_type: [
        type: :string,
        doc:
          "A name for what kind of thing this is, shows up next to it in search results. i.e Module, or Guide. Defaults to the last part of the module name."
      ],
      weight_content: [
        type: {:or, [:float, :integer]},
        doc: "A static amount to add to the `match_rank` when determining how relevant content is"
      ],
      name_attribute: [
        type: :atom,
        default: :name,
        doc: "The name field to be used in search"
      ],
      sanitized_name_attribute: [
        type: :atom,
        doc:
          "The name of the attribute to store the sanitized name in. If not set, will default to the `sanitized_<name_attribute>`"
      ],
      has_name_attribute?: [
        type: :boolean,
        default: true,
        doc:
          "Whether or not the name attribute will be sanitized by default. If not, you should have a change on the resource that sets it."
      ],
      show_docs_on: [
        type: {:or, [:atom, {:list, :atom}]},
        doc:
          "An attribute/calculation/aggregate that should map to a sanitized name that should match to signal that docs should be loaded"
      ],
      use_path_for_name?: [
        type: :boolean,
        default: false,
        doc:
          "Whether or not to write to the sanitized name attribute automatically by stripping the name of special characters"
      ],
      add_name_to_path?: [
        type: :boolean,
        default: true,
        doc: "Whether or not to add the name to the path when using use_path_for_name?"
      ],
      doc_attribute: [
        type: :atom,
        doc: "The text field to be used in the search"
      ],
      load_for_search: [
        type: {:list, :any},
        default: [],
        doc: "A list of fields to load in order to display the item properly in search"
      ]
    ]
  }
  use Spark.Dsl.Extension,
    sections: [@search],
    transformers: [AshHq.Docs.Extensions.Search.Transformers.AddSearchStructure]

  def name_attribute(resource) do
    Extension.get_opt(resource, [:search], :name_attribute, :name)
  end

  def item_type(resource) do
    Extension.get_opt(resource, [:search], :item_type, nil) ||
      resource |> Module.split() |> List.last() |> to_string()
  end

  def type(resource) do
    Extension.get_opt(resource, [:search], :type, "DSL")
  end

  def doc_attribute(resource) do
    Extension.get_opt(resource, [:search], :doc_attribute, nil)
  end

  # sobelow_skip ["DOS.BinToAtom"]
  def sanitized_name_attribute(resource) do
    Extension.get_opt(
      resource,
      [:search],
      :sanitized_name_attribute,
      :"sanitized_#{name_attribute(resource)}"
    )
  end

  def has_name_attribute?(resource) do
    Extension.get_opt(
      resource,
      [:search],
      :has_name_attribute?,
      true
    )
  end

  def weight_content(resource) do
    Extension.get_opt(
      resource,
      [:search],
      :weight_content,
      0
    )
  end

  def use_path_for_name?(resource) do
    Extension.get_opt(
      resource,
      [:search],
      :use_path_for_name?,
      false
    )
  end

  def show_docs_on(resource) do
    Extension.get_opt(
      resource,
      [:search],
      :show_docs_on,
      sanitized_name_attribute(resource)
    )
    |> List.wrap()
  end

  def load_for_search(resource) do
    Extension.get_opt(resource, [:search], :load_for_search, :library_version_id)
  end
end
