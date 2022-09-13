defmodule AshHqWeb.Components.Docs.Functions do
  use Surface.Component

  import AshHqWeb.Helpers
  alias AshHqWeb.Components.Docs.SourceLink

  prop type, :atom, required: true
  prop functions, :list, required: true
  prop header, :string, required: true
  prop library, :any, required: true
  prop library_version, :any, required: true
  prop libraries, :list, required: true
  prop selected_versions, :map, required: true

  def render(assigns) do
    ~F"""
    {#case Enum.filter(@functions, &(&1.type == @type))}
      {#match []}
      {#match functions}
        <h1>{@header}</h1>
        {#for function <- functions}
          <div
            id={"#{@type}-#{function.sanitized_name}-#{function.arity}"}
            class="nav-anchor rounded-lg bg-base-dark-400 dark:bg-base-dark-700 bg-opacity-50 px-2"
          >
            <p class="">
              <div class="">
                <div class="flex flex-row items-baseline">
                  <a href={"##{@type}-#{function.sanitized_name}-#{function.arity}"}>
                    <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                  </a>
                  <div class="text-xl font-semibold mb-2">{function.name}/{function.arity} <SourceLink module_or_function={function} library={@library} library_version={@library_version} />
                  </div>
                </div>
                {#for head <- function.heads}
                  <code class="makeup elixir">{head}</code>
                {/for}
                {raw(render_replacements(@libraries, @selected_versions, function.html_for))}
              </div>
            </p>
          </div>
        {/for}
    {/case}
    """
  end
end
