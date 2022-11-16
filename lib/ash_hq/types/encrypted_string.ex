defmodule AshHq.Types.EncryptedString do
  @moduledoc "Represents a string that is encrypted when cast as input"
  use Ash.Type

  @impl true
  def storage_type, do: :binary

  @impl true
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(value, _) do
    AshHq.Vault.encrypt(value)
  end

  @impl true
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, _) when is_binary(value) do
    {:ok, value}
  end

  def cast_stored(_, _), do: :error

  @impl true
  def dump_to_native(nil, _), do: {:ok, nil}
  def dump_to_native(value, _) when is_binary(value), do: {:ok, value}
  def dump_to_native(_, _), do: :error
end
