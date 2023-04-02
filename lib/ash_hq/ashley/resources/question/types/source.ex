defmodule AshHq.Ashley.Question.Types.Source do
  @moduledoc false
  use Ash.Resource,
    data_layer: :embedded

  actions do
    create :create do
      primary?(true)
      allow_nil_input([:name])

      change(fn changeset, _ ->
        if Ash.Changeset.get_attribute(changeset, :name) do
          changeset
        else
          Ash.Changeset.force_change_attribute(
            changeset,
            :name,
            Ash.Changeset.get_attribute(changeset, :link)
          )
        end
      end)
    end
  end

  attributes do
    attribute :link, :string do
      allow_nil?(false)
    end

    attribute :name, :string do
      allow_nil?(false)
    end
  end
end
