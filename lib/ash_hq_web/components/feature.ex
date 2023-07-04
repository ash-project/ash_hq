defmodule AshHqWeb.Components.Feature do
  @moduledoc "A feature in the home page feature exposè"
  use Surface.Component

  import AshHqWeb.Tails

  prop name, :string, required: true
  prop class, :string, default: nil

  slot icon
  slot description

  def render(assigns) do
    ~F"""
    <div class="flex flex-col items-center">
      <div class={classes(["w-16 h-16 text-primary-light-600 dark:text-primary-dark-400", @class])}>
        <#slot {@icon} />
      </div>
      <div class="font-bold text-3xl mt-4">
        {@name}
      </div>
      <div class="text-xl mt-4">
        <#slot {@description} />
      </div>
    </div>
    """
  end
end
