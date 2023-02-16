defmodule AshHq.Calculations.Decrypt do
  @moduledoc "Decrypts a given value on demand"
  use Ash.Calculation

  def calculate(records, opts, _) do
    {:ok,
     Enum.map(records, fn record ->
       record
       |> Map.get(opts[:field])
       |> case do
         nil ->
           nil

         value ->
           value
           |> Base.decode64!()
           |> AshHq.Vault.decrypt!()
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
