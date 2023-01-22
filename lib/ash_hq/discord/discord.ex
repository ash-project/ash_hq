defmodule AshHq.Discord do
  @moduledoc "Discord api import & interactions"
  use Ash.Api

  resources do
    registry(AshHq.Discord.Registry)
  end
end
