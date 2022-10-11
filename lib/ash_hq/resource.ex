defmodule AshHq.Resource do
  @moduledoc "AshHq's base resource."
  defmacro __using__(opts) do
    quote do
      use Ash.Resource, unquote(opts)

      import AshHq.Calculations.Decrypt, only: [decrypt: 1]
    end
  end
end
