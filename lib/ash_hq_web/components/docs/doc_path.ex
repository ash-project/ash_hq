defmodule AshHqWeb.Components.Docs.DocPath do
  @moduledoc "Renders breadcrumbs to the path of the doc currently being viewed"
  use Surface.Component

  alias AshHqWeb.Components.CalloutText

  prop doc_path, :list, required: true

  def render(assigns) do
    ~F"""
    <div class="flex flex-row space-x-1 items-center overflow-hidden">
      {#case @doc_path}
        {#match [item]}
          <div class="dark:text-white">
            {item}
          </div>
        {#match path}
          {#for item <- :lists.droplast(path)}
            <span class="text-base-light-400">
              {item}
            </span>
            <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
          {/for}
          <span class="dark:text-white overflow-hidden" phx-hook="TextOverflow" id="doc-path">
            <CalloutText
              text={List.last(path)}
              class="overflow-hidden block text-ellipsis whitespace-nowrap"
            />
          </span>
      {/case}
    </div>
    """
  end
end
