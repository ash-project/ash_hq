defmodule AshHq.Github do
  @moduledoc "Domain for interacting with data synchronized from github."
  use Ash.Domain

  resources do
    resource AshHq.Github.Contributor
  end
end
