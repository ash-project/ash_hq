defmodule AshHqWeb.Components.Docs.Functions do
  @moduledoc "Lists all of the provided functions"
  use Surface.Component

  alias AshHqWeb.Components.Docs.SourceLink

  prop(type, :atom, required: true)
  prop(functions, :list, required: true)
  prop(header, :string, required: true)
  prop(library, :any, required: true)
  prop(library_version, :any, required: true)
  prop(libraries, :list, required: true)
  prop(selected_versions, :map, required: true)

  def render(assigns) do
    ~F"""
    {#case Enum.filter(@functions, &(&1.type == @type))}
      {#match []}
      {#match functions}
        <h3>{@header}</h3>
        {#for function <- functions}
          <div id={"#{@type}-#{function.sanitized_name}-#{function.arity}"} class="nav-anchor mb-8">
            <div class="w-full">
              <div class="flex flex-row items-center bg-opacity-50 py-1 bg-base-light-200 dark:bg-base-dark-750 w-full border-l-2 border-primary-light-400 dark:border-primary-dark-400 pl-2">
                <a href={"##{@type}-#{function.sanitized_name}-#{function.arity}"}>
                  <Heroicons.Outline.LinkIcon class="h-3 w-3 mr-2" />
                </a>
                <div class="flex flex-row items-center justify-between w-full pr-2">
                  <div class="text-lg w-full font-semibold">{function.name}/{function.arity}</div>
                  <span class="text-sm"><SourceLink module_or_function={function} library={@library} library_version={@library_version} /></span>
                </div>
              </div>
              <div :if={function.deprecated} class="mt-2 px-2 py-1 bg-yellow-400 text-black">
                <Heroicons.Solid.ExclamationIcon class="w-6 h-6 fill-black inline-block" />
                Deprecated: {function.deprecated}
              </div>
              <div class="p-2">
                {raw(rendered(function.doc_html))}
              </div>
            </div>
          </div>
        {/for}
    {/case}
    """
  end

  defp rendered(html) do
    html
    |> String.split("<!--- heads-end -->")
    |> case do
      [] ->
        ""

      [string] ->
        string

      [heads, docs] ->
        if String.trim(docs) == "" do
          """
          <div class="not-prose">
            #{heads}
          </div>

          #{docs}
          """
        else
          """
          <div class="not-prose border-b dark:border-base-dark-400 pb-2">
            #{heads}
          </div>

          #{docs}
          """
        end
    end
  end
end
