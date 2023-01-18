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
            <div class="bg-base-light-200 dark:bg-base-dark-700 w-full rounded-lg">
              <div class="flex flex-row items-center bg-opacity-50 py-1 rounded-t-lg bg-base-light-300 dark:bg-base-dark-850 w-full">
                <a href={"##{@type}-#{function.sanitized_name}-#{function.arity}"}>
                  <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                </a>
                <div class="flex flex-row items-center justify-between w-full pr-2">
                  <div class="text-xl w-full font-semibold">{function.name}/{function.arity}</div>
                  <SourceLink module_or_function={function} library={@library} library_version={@library_version} />
                </div>
              </div>
              <div class="p-4">
                {raw(rendered(function.html))}
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
          <div class="not-prose border-b pb-2">
            #{heads}
          </div>

          #{docs}
          """
        end
    end
  end
end
