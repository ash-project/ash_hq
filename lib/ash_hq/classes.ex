defmodule AshHq.Classes do
  @moduledoc "Static values for tailwind colors"

  @colors "assets/tailwind.colors.json"
          |> File.read!()
          |> Jason.decode!()

  def classes(classes) when is_list(classes) do
    classes
    |> Enum.filter(fn
      {_classes, condition} ->
        condition

      _ ->
        true
    end)
    |> Enum.join(" ")
  end

  def classes(classes) when is_binary(classes) do
    classes
  end

  def classes(base, classes) do
    merge(classes(base), classes(classes))
  end

  def merge(base, extension) do
    AshHq.Tailwind.merge(base, extension)
  end

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
