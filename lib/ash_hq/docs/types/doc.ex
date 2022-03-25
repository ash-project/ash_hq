defmodule AshHq.Docs.Types.Doc do
  use Ash.Type

  def cast_input(nil, _), do: nil

  def cast_input(value, _) when is_binary(value) do
    {:ok, Earmark.as_html!(value)}
  end

  def cast_stored(value, _), do: {:ok, value}

  def dump_to_native(value, _), do: {:ok, value}
end
