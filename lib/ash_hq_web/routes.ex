defmodule AshHqWeb.Routes do
  @moduledoc "Route helpers"
  def url(path) do
    Application.get_env(:ash_hq, :url) <> "/" <> String.trim_leading(path, "/")
  end
end
