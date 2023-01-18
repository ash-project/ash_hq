defmodule AshHq.Docs.Library.Agent do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def get() do
    Agent.get_and_update(__MODULE__, fn state ->
      state =
        if state == nil do
          AshHq.Docs.Library.read!(%{check_cache: false})
        else
          state
        end

      {state, state}
    end)
  end

  def clear() do
    Agent.update(__MODULE__, fn _state ->
      nil
    end)
  end
end
