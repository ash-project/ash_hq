defmodule AshHq.Docs.Extensions.Search do
  alias Ash.Dsl.Extension

  @search %Ash.Dsl.Section{
    name: :search,
    schema: [
      name_attribute: [
        type: :atom,
        default: :name,
        doc: "The name field to be used in search"
      ],
      library_version_attribute: [
        type: :atom,
        default: :library_version_id,
        doc: "The attribute to use to filter by library version"
      ],
      load_for_search: [
        type: {:list, :atom},
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

  def library_version_attribute(resource) do
    Extension.get_opt(resource, [:search], :library_version_attribute, :library_version_id)
  end

  def load_for_search(resource) do
    Extension.get_opt(resource, [:search], :load_for_search, :library_version_id)
  end
end
