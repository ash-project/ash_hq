defmodule AshHqWeb.Components.RightNav do
  use Surface.Component

  alias AshHqWeb.Routes
  alias Surface.Components.LivePatch

  prop functions, :list

  def render(assigns) do
    ~F"""
    <div class="w-min flex flex-col overflow-y-scroll">
      {#for function <- @functions}
        <a class="hover:text-orange-300" href={"##{Routes.sanitize_name(function.name)}-#{function.arity}"}>
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}
    </div>
    """
  end
end
