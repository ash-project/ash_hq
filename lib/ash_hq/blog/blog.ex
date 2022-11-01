defmodule AshHq.Blog do
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
