defmodule AshHq.Docs.Option do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "options"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Docs
    define :search, args: [:query, :library_versions]
    define :read
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :type, :string do
      allow_nil? false
    end

    attribute :doc, :string

    attribute :required, :boolean do
      allow_nil? false
      default false
    end

    attribute :default, :string
    attribute :path, {:array, :string}
  end

  actions do
    read :read do
      primary? true
    end

    read :search do
      argument :query, :string do
        allow_nil? false
      end

      argument :library_versions, {:array, :uuid} do
        allow_nil? false
      end

      prepare AshHq.Docs.Preparations.LoadSearchData
      filter expr(matches(query: arg(:query)) and library_version_id in ^arg(:library_versions))
    end

    create :create do
      argument :library_version, :uuid
      change manage_relationship(:library_version, type: :replace)
    end
  end

  calculations do
    calculate :search_headline,
              :string,
              expr(
                fragment(
                  "ts_headline('english', ?, to_tsquery('english', ?  || ':*'), 'MaxFragments=3, StartSel=\"<span class=\"\"search-hit\"\">\", StopSel=</span>')",
                  doc,
                  ^arg(:query)
                )
              ) do
      argument :query, :string do
        allow_nil? false
      end
    end

    calculate :matches,
              :boolean,
              expr(
                fragment(
                  "setweight(to_tsvector(?), 'A') || setweight(to_tsvector(?), 'D') @@ to_tsquery(? || ':*')",
                  name,
                  doc,
                  ^arg(:query)
                )
              ) do
      argument :query, :string do
        allow_nil? false
      end
    end

    calculate :match_rank,
              :float,
              expr(
                fragment(
                  "ts_rank(setweight(to_tsvector(?), 'A') || setweight(to_tsvector(?), 'D'),  to_tsquery(?))",
                  name,
                  doc,
                  ^arg(:query)
                )
              ) do
      argument :query, :string do
        allow_nil? false
      end
    end
  end

  aggregates do
    first :extension_type, [:dsl, :extension], :type
  end

  relationships do
    belongs_to :dsl, AshHq.Docs.Dsl do
      required? true
    end

    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end
  end
end
