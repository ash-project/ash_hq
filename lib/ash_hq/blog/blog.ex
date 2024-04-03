defmodule AshHq.Blog do
  @moduledoc "A domain for interacting with the blog"
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show? true
    default_resource_page :primary_read
  end

  resources do
    resource AshHq.Blog.Post
    resource AshHq.Blog.Tag
  end
end
