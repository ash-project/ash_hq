defmodule AshHqWeb.AuthOverrides do
  @moduledoc "UI overrides for authentication views"
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components

  override Components.HorizontalRule do
    set :root_class, "hidden"
  end
end
