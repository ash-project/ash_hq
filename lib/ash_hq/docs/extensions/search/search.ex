defmodule AshHq.Docs.Extensions.Search do
  alias Ash.Dsl.Extension

  @search %Ash.Dsl.Section{
    name: :search,
    schema: [
      type: [
        type: :string,
        default: "DSL",
        doc: "The type of item. Used to narrow down search results, displayed in the UI."
      ],
      name_attribute: [
        type: :atom,
        default: :name,
        doc: "The name field to be used in search"
      ],
      doc_attribute: [
        type: :atom,
        default: :doc,
        doc: "The text field to be used in the search"
      ],
      library_version_attribute: [
        type: :atom,
        default: :library_version_id,
        doc: "The attribute to use to filter by library version"
      ],
      load_for_search: [
        type: {:list, :any},
        default: [],
        doc: "A list of fields to load in order to display the item properly in search"
      ]
    ]
  }
  use Ash.Dsl.Extension,
    sections: [@search],
    transformers: [AshHq.Docs.Extensions.Search.Transformers.AddSearchStructure]

  def name_attribute(resource) do
    Extension.get_opt(resource, [:search], :name_attribute, :name)
  end

  def type(resource) do
    Extension.get_opt(resource, [:search], :type, "DSL")
  end

  def doc_attribute(resource) do
    Extension.get_opt(resource, [:search], :doc_attribute, :name)
  end

  def library_version_attribute(resource) do
    Extension.get_opt(resource, [:search], :library_version_attribute, :library_version_id)
  end

  def load_for_search(resource) do
    Extension.get_opt(resource, [:search], :load_for_search, :library_version_id)
  end
end
