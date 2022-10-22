defmodule AshHqWeb.Components.Docs.SourceLink do
  use Surface.Component
  import AshHqWeb.Helpers

  prop module_or_function, :any, required: true
  prop library, :any, required: true
  prop library_version, :any, required: true

  def render(assigns) do
    ~F"""
    {#if @module_or_function.file}
      <a href={source_link(@module_or_function, @library, @library_version)}>{"</>"}</a>
    {/if}
    """
  end
end
