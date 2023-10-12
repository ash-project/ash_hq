defmodule AshHq.Docs.Library.Agent do
  @moduledoc "A simple cache for the list of libraries"
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get do
    Agent.get_and_update(__MODULE__, fn state ->
      state =
        if state == nil do
          AshHq.Docs.Library.read!(%{check_cache: false},
            load: [
              :latest_version_id,
              latest_library_version: [guides: Ash.Query.select(AshHq.Docs.Guide, :name)]
            ]
          )
        else
          state
        end

      {state, state}
    end)
  end

  def clear do
    Agent.update(__MODULE__, fn _state ->
      nil
    end)
  end
end
