defmodule AshHq.Blog.Tag do
  @moduledoc "A tag that can be applied to a post. Currently uses CSV data layer and therefore is static"
  use Ash.Resource,
    data_layer: AshCsv.DataLayer

  csv do
    file "priv/blog/tags.csv"
    create? true
    header? true
    columns [:name]
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    create :upsert do
      accept [:name]
      upsert? true
    end
  end

  attributes do
    attribute :name, :ci_string do
      allow_nil? false
      primary_key? true
      constraints casing: :lower
    end
  end

  code_interface do
    define_for AshHq.Blog
    define :upsert, args: [:name]
    define :read
    define :destroy
  end
end
