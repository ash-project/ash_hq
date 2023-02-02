defmodule AshHqWeb.Components.DocSidebarDslItems do
  @moduledoc """
  Surface component for generating the recursive TreeView items for an extension DSL.
  """
  use Surface.Component

  alias __MODULE__
  alias AshHqWeb.Components.DocSidebar
  alias AshHqWeb.Components.TreeView
  alias AshHqWeb.DocRoutes

  @doc "List of DSLs for an extension"
  prop dsls, :list, required: true

  @doc "The path of the DSL to display"
  prop dsl_path, :string, required: true

  @doc "Selected library versions"
  prop selected_versions, :map, required: true

  @doc "Currently selected DSL"
  prop dsl, :struct

  def render(assigns) do
    ~F"""
    <TreeView.Item
      :for={dsl <- Enum.filter(@dsls, fn dsl -> dsl.path == @dsl_path end)}
      name={DocSidebar.slug(dsl.name)}
      text={dsl.name}
      collapsable={false}
      selected={@dsl && @dsl.id == dsl.id}
      to={DocRoutes.doc_link(dsl, @selected_versions)}
      indent_guide
      class={"pt-2": Enum.any?(@dsls, &(&1.path == @dsl_path ++ [dsl.name]))}
    >
      <DocSidebarDslItems
        selected_versions={@selected_versions}
        dsls={@dsls}
        dsl={@dsl}
        dsl_path={@dsl_path ++ [dsl.name]}
      />
    </TreeView.Item>
    """
  end
end
