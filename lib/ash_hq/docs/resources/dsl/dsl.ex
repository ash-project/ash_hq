defmodule AshHq.Docs.Dsl do
  use AshHq.Resource,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "dsls"
    repo AshHq.Repo
  end

  code_interface do
    define_for AshHq.Docs
    define :search, args: [:query, :library_versions]
    define :read
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
      argument :options, {:array, :map}
      argument :library_version, :uuid

      change {AshHq.Docs.Changes.AddArgToRelationship, arg: :library_version, rel: :options}
      change manage_relationship(:options, type: :direct_control)
      change manage_relationship(:library_version, type: :replace)
    end

    update :update do
      argument :options, {:array, :map}
      argument :library_version, :uuid

      change {AshHq.Docs.Changes.AddArgToRelationship, arg: :library_version, rel: :options}
      change manage_relationship(:options, type: :direct_control)
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
                fragment("to_tsvector(? || ?) @@ to_tsquery(? || ':*')", name, doc, ^arg(:query))
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

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :doc, :string
    attribute :examples, {:array, :string}
    attribute :args, {:array, :string}
    attribute :path, {:array, :string}
    attribute :recursive_as, :string

    attribute :type, :atom do
      allow_nil? false
      constraints one_of: [:entity, :section]
    end
  end

  aggregates do
    first :extension_type, :extension, :type
  end

  relationships do
    belongs_to :library_version, AshHq.Docs.LibraryVersion do
      required? true
    end

    belongs_to :extension, AshHq.Docs.Extension do
      required? true
    end

    belongs_to :dsl, __MODULE__
    has_many :options, AshHq.Docs.Option
    has_many :dsls, __MODULE__
  end
end
