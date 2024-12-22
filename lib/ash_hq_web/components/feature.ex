defmodule AshHqWeb.Components.Feature do
  @moduledoc "A feature in the home page feature exposè"
  use Phoenix.Component

  import Tails

  attr :name, :string, required: true
  attr :class, :string, default: nil

  slot :icon
  slot :description

  def feature(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <div class={classes(["w-16 h-16 text-primary-light-600 dark:text-primary-dark-400", @class])}>
        {render_slot(@icon)}
      </div>
      <div class="font-bold text-3xl mt-4">
        {@name}
      </div>
      <div class="text-xl mt-4">
        {render_slot(@description)}
      </div>
    </div>
    """
  end
end
