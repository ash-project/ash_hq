defmodule AshHqWeb.Helpers do
  @moduledoc "Simple helpers for doc liveviews"

  def latest_version(library) do
    Enum.find(library.versions, fn version ->
      !String.contains?(version.version, ".")
    end) || Enum.at(library.versions, 0)
  end
end
