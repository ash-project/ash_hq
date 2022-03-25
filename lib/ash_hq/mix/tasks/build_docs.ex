defmodule Mix.Tasks.AshHq.BuildDocs do
  @moduledoc "The hello mix task: `mix help hello`"
  use Mix.Task

  @shortdoc "Builds documentation for any versions"
  def run(_) do
    Mix.Task.run("app.start")
    AshHq.Docs.Importer.Builder.build()
  end
end
