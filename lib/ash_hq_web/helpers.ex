defmodule AshHqWeb.Helpers do
  @moduledoc "Simple helpers for doc liveviews"

  require Logger

  def latest_version(library) do
    case library.versions do
      [] ->
        nil

      versions ->
        Enum.min(versions, &(Version.compare(&1.version, &2.version) != :lt))
    end
  end

  def source_link(%AshHq.Docs.Module{file: file}, library, library_version) do
    "https://github.com/#{library.repo_org}/#{library.name}/tree/v#{library_version.version}/#{file}"
  end

  def source_link(%AshHq.Docs.MixTask{file: file}, library, library_version) do
    "https://github.com/#{library.repo_org}/#{library.name}/tree/v#{library_version.version}/#{file}"
  end

  def source_link(%AshHq.Docs.Function{file: file, line: line}, library, library_version) do
    if line do
      "https://github.com/#{library.repo_org}/#{library.name}/tree/v#{library_version.version}/#{file}#L#{line}"
    else
      "https://github.com/#{library.repo_org}/#{library.name}/tree/v#{library_version.version}/#{file}"
    end
  end

  def source_link(%AshHq.Docs.Guide{route: route}, library, library_version) do
    "https://github.com/#{library.repo_org}/#{library.name}/tree/v#{library_version.version}/documentation/#{route}.md"
  end

  def hex_link(%AshHq.Docs.Guide{route: route}, library, _library_version) do
    name = route |> Path.split() |> List.last() |> String.replace(".", "-")
    "https://hexdocs.pm/#{library.name}/#{name}.html"
  end
end
