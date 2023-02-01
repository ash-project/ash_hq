defmodule AshHq.Docs.Search.Types.TsVector do
  use Ash.Type

  def storage_type, do: :tsvector
  def cast_in_query?(_), do: false

  defdelegate cast_input(value, constraints), to: Ash.Type.String
  defdelegate cast_stored(value, constraints), to: Ash.Type.String
  defdelegate dump_to_native(value, constraints), to: Ash.Type.String
end
