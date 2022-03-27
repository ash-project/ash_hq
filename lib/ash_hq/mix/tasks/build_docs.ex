defmodule Mix.Tasks.AshHq.ImportDocs do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  @shortdoc "Builds documentation for any versions"
  def run(_) do
    Mix.Task.run("app.start")
    AshHq.Docs.Importer.import()
  end
end
