defmodule AshHq.Docs.Extensions.RenderMarkdown.PostProcessors.Highlighter do
  @moduledoc false
  # Copied *directly* from nimble_publisher
  # https://github.com/dashbitco/nimble_publisher/blob/v0.1.2/lib/nimble_publisher/highlighter.ex

  use AshHqWeb, :verified_routes

  def highlight(ast, _libraries, _current_library, _current_module) do
    ast
  end
end
