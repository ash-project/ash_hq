[
  import_deps: [:ecto, :phoenix, :ash, :ash_postgres, :surface],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  plugins: [Spark.Formatter],
  locals_without_parens: [
    name_attribute: 1,
    library_version_attribute: 1,
    load_for_search: 1,
    doc_attribute: 1,
    render_attributes: 1,
    use_path_for_name?: 1,
    sanitized_name_attribute: 1,
    show_docs_on: 1,
    header_ids?: 1
  ]
]
