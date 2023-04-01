defmodule AshHq.Ashley do
  use Ash.Api

  resources do
    registry AshHq.Ashley.Registry
  end

  authorization do
    authorize :by_default
  end
end
