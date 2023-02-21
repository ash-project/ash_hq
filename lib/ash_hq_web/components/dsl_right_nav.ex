defmodule AshHqWeb.Components.DslRightNav do
  @moduledoc "The right nav shown for Dsls."
  use Surface.Component

  prop dsls, :list, default: []
  prop dsl_target, :string, required: true

  def render(assigns) do
    ~F"""
    <style>
      a[aria-current] {
      @apply text-primary-light-600 dark:text-primary-dark-400;
      }
    </style>
    <div id="right-nav" class="scroll-parent hidden lg:flex flex-col pb-12" phx-hook="RightNav">
      <a
        id="right-nav-module-docs"
        class="hover:text-primary-light-300 hover:dark:text-primary-dark-300 right-nav"
        href="#module-docs"
      >
        {@dsl_target}
      </a>
      {#for %{path: []} = dsl <- @dsls}
        {render_dsl_nav(assigns, dsl)}
      {/for}
    </div>
    """
  end

  defp render_dsl_nav(assigns, dsl) do
    ~F"""
    <div class={if dsl.path == [], do: "", else: "ml-2"}>
      <.nav_link dsl={dsl} />
      {#for dsl <- child_dsls(@dsls, dsl)}
        {render_dsl_nav(assigns, dsl)}
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
      id={"right-nav-#{String.replace(@dsl.sanitized_path, "/", "-")}"}
      class="hover:text-primary-light-300 hover:dark:text-primary-dark-300 right-nav"
      href={"##{String.replace(@dsl.sanitized_path, "/", "-")}"}
    >
      {"#{@dsl.name}"}
    </a>
    """
  end

  defp child_dsls(dsls, dsl) do
    dsl_path = dsl.path ++ [dsl.name]
    dsl_path_count = Enum.count(dsl_path)

    Enum.filter(dsls, fn potential_child ->
      potential_child_path = potential_child.path ++ [potential_child.name]

      List.starts_with?(potential_child_path, dsl_path) &&
        Enum.count(potential_child_path) - dsl_path_count == 1
    end)
  end
end
