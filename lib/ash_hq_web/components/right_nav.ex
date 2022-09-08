defmodule AshHqWeb.Components.RightNav do
  @moduledoc "The right nav shown for functions in a module."
  use Surface.Component

  prop functions, :list, default: []
  prop module, :string, required: true

  def render(assigns) do
    ~F"""
    <div id="right-nav" class="w-min hidden lg:flex flex-col overflow-y-auto" phx-hook="RightNav">
      <a id="right-nav-module-docs" class="hover:text-primary-light-300 right-nav" href="#module-docs">
        {@module}
      </a>
      {#for %{type: :callback} = function <- @functions}
        <a
          id={"right-nav-callback-#{function.sanitized_name}-#{function.arity}"}
          class="hover:text-primary-light-300 right-nav"
          href={"#function-#{function.sanitized_name}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}

      {#for %{type: :function} = function <- @functions}
        <a
          id={"right-nav-function-#{function.sanitized_name}-#{function.arity}"}
          class="hover:text-primary-light-300 right-nav"
          href={"#function-#{function.sanitized_name}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}

      {#for %{type: :macro} = function <- @functions}
        <a
          id={"right-nav-macro-#{function.sanitized_name}-#{function.arity}"}
          class="hover:text-primary-light-300 right-nav"
          href={"#macro-#{function.sanitized_name}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}
    </div>
    """
  end
end
