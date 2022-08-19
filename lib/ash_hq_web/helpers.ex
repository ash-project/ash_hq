defmodule AshHqWeb.Helpers do
  @moduledoc "Simple helpers for doc liveviews"

  def latest_version(library) do
    Enum.at(library.versions, 0)
  end
end
