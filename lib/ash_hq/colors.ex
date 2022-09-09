defmodule AshHq.Colors do
  @moduledoc "Static values for tailwind colors"

  @colors "assets/tailwind.colors.json"
          |> File.read!()
          |> Jason.decode!()

  for {key, value} when is_binary(value) <- @colors do
    # sobelow_skip ["DOS.BinToAtom"]
    def unquote(:"#{String.replace(key, "-", "_")}")() do
      unquote(value)
    end
  end

  for {key, value} when is_map(value) <- @colors do
    for {suffix, value} when is_binary(value) <- value do
      if suffix == "DEFAULT" do
        # sobelow_skip ["DOS.BinToAtom"]
        def unquote(:"#{String.replace(key, "-", "_")}")() do
          unquote(value)
        end
      else
        # sobelow_skip ["DOS.BinToAtom"]
        def unquote(:"#{String.replace(key, "-", "_")}_#{String.replace(suffix, "-", "_")}")() do
          unquote(value)
        end
      end
    end
  end
end
