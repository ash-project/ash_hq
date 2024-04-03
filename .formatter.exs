[
  import_deps: [
    :ecto,
    :phoenix,
    :ash,
    :ash_postgres,
    :ash_graphql,
    :ash_admin,
    :ash_csv,
    :ash_oban
  ],
  inputs: [
    "*.{ex,exs}",
    "priv/*/seeds.exs",
    "priv/repo/**/*.{ex,exs}",
    "priv/scripts/**/*.{ex,exs}",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  plugins: [Spark.Formatter],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [
    has_name_attribute?: 1,
    name_attribute: 1,
    load_for_search: 1,
    doc_attribute: 1,
    render_attributes: 1,
    use_path_for_name?: 1,
    add_name_to_path?: 1,
    item_type: 1,
    sanitized_name_attribute: 1,
    show_docs_on: 1,
    header_ids?: 1,
    table_of_contents?: 1
  ]
]
