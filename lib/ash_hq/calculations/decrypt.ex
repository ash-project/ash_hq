defmodule AshHq.Calculations.Decrypt do
  @moduledoc "Decrypts a given value on demand"
  use Ash.Calculation

  def decrypt(field) do
    {__MODULE__, field: field}
  end

  def calculate(records, opts, _) do
    {:ok,
     Enum.map(records, fn record ->
       record
       |> Map.get(opts[:field])
       |> case do
         nil ->
           nil

         value ->
           AshHq.Vault.decrypt!(value)
       end
     end)}
  end

  def select(_, opts, _) do
    [opts[:field]]
  end

  def load(_, opts, _) do
    [opts[:field]]
  end
end
