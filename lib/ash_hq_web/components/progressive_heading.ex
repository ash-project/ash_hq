defmodule AshHqWeb.Components.ProgressiveHeading do
  use Surface.Component

  prop depth, :integer, required: true
  slot default, required: true

  def render(assigns) do
    ~F"""
    {#case @depth}
      {#match 1}
        <h1>
          <#slot />
        </h1>
      {#match 2}
        <h2>
          <#slot />
        </h2>
      {#match 3}
        <h3>
          <#slot />
        </h3>
      {#match 4}
        <h4>
          <#slot />
        </h4>
      {#match 5}
        <h5>
          <#slot />
        </h5>
      {#match 6}
        <h6>
          <#slot />
        </h6>
      {#match 7}
        <span>
          <#slot />
        </span>
      {#match 8}
        <span>
          <#slot />
        </span>
      {#match 9}
        <span>
          <#slot />
        </span>
    {/case}
    """
  end
end
