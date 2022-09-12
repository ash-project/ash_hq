defmodule AshHq.Tailwind do
  defstruct [:p, :m, :w, classes: MapSet.new()]

  defmodule Directions do
    defstruct [:l, :r, :t, :b, :x, :y, :all]

    @type t :: %__MODULE__{
            l: String.t(),
            r: String.t(),
            t: String.t(),
            b: String.t(),
            x: String.t(),
            y: String.t()
          }
  end

  @type directional_value :: String.t() | Directions.t()

  @type t :: %__MODULE__{
          p: directional_value(),
          m: directional_value(),
          w: String.t()
        }

  def new(classes) do
    merge(%__MODULE__{}, classes)
  end

  @doc """
  Semantically merges two lists of tailwind classes, treating the first as a base and the second as overrides

  Examples

      iex> merge("p-4", "p-2") |> to_string()
      "p-2"
      iex> merge("p-2", "p-4") |> to_string()
      "p-4"
      iex> merge("p-4", "px-2") |> to_string()
      "px-2 py-4"
  """
  def merge(tailwind, classes) when is_binary(tailwind) do
    merge(new(tailwind), classes)
  end

  def merge(tailwind, classes) when is_binary(classes) do
    classes
    |> String.split()
    |> Enum.reduce(tailwind, &merge_class(&2, &1))
  end

  def merge(tailwind, %__MODULE__{} = classes) do
    merge(tailwind, to_string(classes))
  end

  def merge(_tailwind, value) do
    raise "Cannot merge #{inspect(value)}"
  end

  @directional ~w(p m)a

  for class <- @directional do
    string_class = to_string(class)

    def merge_class(tailwind, unquote(string_class) <> "-" <> value) do
      Map.put(tailwind, unquote(class), value)
    end

    def merge_class(%{unquote(class) => nil} = tailwind, unquote(string_class) <> "x-" <> value) do
      Map.put(tailwind, unquote(class), %Directions{x: value})
    end

    def merge_class(%{unquote(class) => all} = tailwind, unquote(string_class) <> "x-" <> value)
        when is_binary(all) do
      Map.put(tailwind, unquote(class), %Directions{y: all, x: value})
    end

    def merge_class(
          %{unquote(class) => %Directions{} = directions} = tailwind,
          unquote(string_class) <> "x" <> value
        ) do
      Map.put(tailwind, unquote(class), %{directions | x: value, l: nil, r: nil})
    end

    def merge_class(%{unquote(class) => nil} = tailwind, unquote(string_class) <> "y-" <> value) do
      Map.put(tailwind, unquote(class), %Directions{y: value})
    end

    def merge_class(%{unquote(class) => all} = tailwind, unquote(string_class) <> "y-" <> value)
        when is_binary(all) do
      Map.put(tailwind, unquote(class), %Directions{x: all, y: value})
    end

    def merge_class(
          %{unquote(class) => %Directions{} = directions} = tailwind,
          unquote(string_class) <> "y-" <> value
        ) do
      Map.put(tailwind, unquote(class), %{directions | y: value, t: nil, b: nil})
    end
  end

  def merge_class(tailwind, class) do
    %{tailwind | classes: MapSet.put(tailwind.classes, class)}
  end

  defimpl String.Chars do
    def to_string(tailwind) do
      [
        directional(tailwind.p, :p),
        directional(tailwind.m, :m),
        Enum.join(tailwind.classes, " ")
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")
    end

    defp directional(nil, _key), do: nil

    defp directional(value, key) when is_binary(value) do
      "#{key}-#{value}"
    end

    defp directional(%Directions{l: l, r: r, t: t, b: b, x: x, y: y}, key) do
      [
        direction(t, :t, key),
        direction(b, :b, key),
        direction(l, :l, key),
        direction(r, :r, key),
        direction(x, :x, key),
        direction(y, :y, key)
      ]
      |> Enum.filter(& &1)
      |> Enum.join(" ")
    end

    defp direction(nil, _, _), do: nil
    defp direction(value, suffix, prefix), do: "#{prefix}#{suffix}-#{value}"
  end

  defimpl Inspect do
    def inspect(tailwind, _opts) do
      "Tailwind.new(\"#{to_string(tailwind)}\")"
    end
  end
end
