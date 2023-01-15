defmodule AshHq.Docs.Dsl.Types.Arg do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    attribute :optional, :boolean do
      default false
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
    end

    attribute :default, :string
  end
end
