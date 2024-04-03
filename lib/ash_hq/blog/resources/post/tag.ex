defmodule AshHq.Blog.Tag do
  @moduledoc "A tag that can be applied to a post. Currently uses CSV data layer and therefore is static"
  use Ash.Resource,
    domain: AshHq.Blog,
    data_layer: AshCsv.DataLayer

  csv do
    file "priv/blog/tags.csv"
    create? true
    header? true
    columns [:name]
  end

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]

    create :upsert do
      accept [:name]
      upsert? true
    end
  end

  attributes do
    attribute :name, :ci_string do
      public? true
      allow_nil? false
      primary_key? true
      constraints casing: :lower
    end
  end

  code_interface do
    define :upsert, args: [:name]
    define :read
    define :destroy
  end
end
