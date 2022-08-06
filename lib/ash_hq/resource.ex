defmodule AshHq.Resource do
  @moduledoc "AshHq's base resource."
  defmacro __using__(opts) do
    quote do
      use Ash.Resource, unquote(opts)
    end
  end
end
