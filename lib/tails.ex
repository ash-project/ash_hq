defmodule Tails do
  def classes(string) when is_binary(string) do
    string
  end

  def classes({class, condition}) do
    if condition do
      to_string(class)
    end
  end

  def classes(classes) when is_list(classes) do
    classes
    |> Enum.map(&classes/1)
    |> Enum.filter(& &1)
    |> Enum.join(" ")
  end
end
