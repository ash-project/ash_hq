defmodule Mix.Tasks.Import do
  @shortdoc "Seeds the database with documentation."
  @moduledoc @shortdoc
  @requirements ["app.start"]

  use Mix.Task
  alias AshHq.Docs.Importer

  @impl Mix.Task
  def run(_args) do
    IO.puts("Beginning documentation import.")
    Importer.import()
    IO.puts("Import complete.")
  end
end
