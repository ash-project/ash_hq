defmodule AshHqWeb.Components.RightNav do
  use Surface.Component

  alias AshHqWeb.Routes

  prop functions, :list, default: []
  prop module, :string, required: true

  def render(assigns) do
    ~F"""
    <div id="right-nav" class="w-min hidden lg:flex flex-col overflow-y-scroll" phx-hook="RightNav">
      <a id="right-nav-module-docs" class="hover:text-orange-300 right-nav" href="#module-docs">
        {@module}
      </a>
      {#for %{type: :callback} = function <- @functions}
        <a
          id={"right-nav-callback-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
          class="hover:text-orange-300 right-nav"
          href={"#function-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}

      {#for %{type: :function} = function <- @functions}
        <a
          id={"right-nav-function-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
          class="hover:text-orange-300 right-nav"
          href={"#macro-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}

      {#for %{type: :macro} = function <- @functions}
        <a
          id={"right-nav-macro-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
          class="hover:text-orange-300 right-nav"
          href={"#macro-#{Routes.sanitize_name(function.name)}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}
    </div>
    """
  end
end
