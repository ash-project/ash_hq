defmodule AshHqWeb.LayoutView do
  use AshHqWeb, :view
  import AshHqWeb.Components.Footer

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}
end
