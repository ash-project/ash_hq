defmodule AshHq.Github.Contributor do
  @moduledoc "A contributor to any package deployed on Ash HQ."
  use Ash.Resource,
    domain: AshHq.Github,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]

    read :in_order do
      prepare build(sort: [order: :asc])
    end

    action :import, :atom do
      constraints one_of: [:ok, :error]

      run AshHq.Github.Contributor.Actions.Import
    end
  end

  oban do
    domain AshHq.Github

    scheduled_actions do
      schedule :import, "0 */6 * * *" do
        queue :importer
      end
    end
  end

  attributes do
    integer_primary_key :id do
      generated? false
      writable? true
    end

    attribute :login, :string, allow_nil?: false, public?: true
    attribute :avatar_url, :string, allow_nil?: false, public?: true
    attribute :html_url, :string, allow_nil?: false, public?: true
    attribute :order, :integer, allow_nil?: false, public?: true
  end

  postgres do
    table "contributors"
    repo AshHq.Repo
  end

  code_interface do

    define :in_order
  end
end
