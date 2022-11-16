defmodule AshHq.Blog do
  @moduledoc "An api for interacting with the blog"
  use Ash.Api,
    extensions: [AshAdmin.Api]

  admin do
    show? true
    default_resource_page :primary_read
  end

  resources do
    registry AshHq.Blog.Registry
  end
end
