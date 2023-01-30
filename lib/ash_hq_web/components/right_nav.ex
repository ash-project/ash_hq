defmodule AshHqWeb.Components.RightNav do
  @moduledoc "The right nav shown for functions in a module."
  use Surface.Component

  prop functions, :list, default: []
  prop module, :string, required: true

  def render(assigns) do
    ~F"""
    <style>
      a[aria-current] {
      @apply text-primary-light-600 dark:text-primary-dark-400;
      }
    </style>
    <div id="right-nav" class="scroll-parent w-min hidden lg:flex flex-col pb-12" phx-hook="RightNav">
      <a
        id="right-nav-module-docs"
        class="hover:text-primary-light-300 hover:dark:text-primary-dark-300 right-nav"
        href="#module-docs"
      >
        {@module}
      </a>
      {#for %{type: :type} = function <- @functions}
        <.nav_link function={function} />
      {/for}

      {#for %{type: :callback} = function <- @functions}
        <.nav_link function={function} />
      {/for}

      {#for %{type: :function} = function <- @functions}
        <.nav_link function={function} />
      {/for}

      {#for %{type: :macro} = function <- @functions}
        <.nav_link function={function} />
      {/for}
    </div>
    """
  end

  def nav_link(assigns) do
    ~F"""
    <style>
      a[aria-current] {
      @apply text-primary-light-600 dark:text-primary-dark-400;
      }
    </style>
    <a
      id={"right-nav-#{@function.type}-#{@function.sanitized_name}-#{@function.arity}"}
      class="hover:text-primary-light-300 hover:dark:text-primary-dark-300 right-nav"
      href={"##{@function.type}-#{@function.sanitized_name}-#{@function.arity}"}
    >
      {"#{@function.name}/#{@function.arity}"}
    </a>
    """
  end
end
