defmodule AshHq.Blog.Registry do
  @moduledoc "The resources used in the blog"
  use Ash.Registry,
    extensions: [Ash.Registry.ResourceValidations]

  entries do
    entry AshHq.Blog.Post
    entry AshHq.Blog.Tag
  end
end
