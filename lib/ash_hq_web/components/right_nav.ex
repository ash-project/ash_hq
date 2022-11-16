defmodule AshHqWeb.Components.RightNav do
  @moduledoc "The right nav shown for functions in a module."
  use Surface.Component

  prop functions, :list, default: []
  prop module, :string, required: true

  def render(assigns) do
    ~F"""
    <style>
      a[aria-current] {
      @apply text-primary-light-600;
      }
      :global(:dark):a[aria-current] {
      @apply text-primary-dark-400;
      }
    </style>
    <div id="right-nav" class="scroll-parent w-min hidden lg:flex flex-col pb-12" phx-hook="RightNav">
      <a id="right-nav-module-docs" class="hover:text-primary-light-300 right-nav" href="#module-docs">
        {@module}
      </a>
      {#for %{type: :type} = function <- @functions}
        <a
          id={"right-nav-type-#{function.sanitized_name}-#{function.arity}"}
          class="hover:text-primary-light-300 right-nav"
          href={"#type-#{function.sanitized_name}-#{function.arity}"}
        >
          {"#{function.name}/#{function.arity}"}
        </a>
      {/for}

      {#for %{type: :callback} = function <- @functions}
        <a
          id={"right-nav-callback-#{function.sanitized_name}-#{function.arity}"}
          class="hover:text-primary-light-300 right-nav"
          href={"#callback-#{function.sanitized_name}-#{function.arity}"}
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
