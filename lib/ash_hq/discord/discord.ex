defmodule AshHq.Discord do
  use Ash.Api

  resources do
    registry AshHq.Discord.Registry
  end
end
