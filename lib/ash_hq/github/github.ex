defmodule AshHq.Github do
  @moduledoc "Api for interacting with data synchronized from github."
  use Ash.Api

  resources do
    resource AshHq.Github.Contributor
  end
end
