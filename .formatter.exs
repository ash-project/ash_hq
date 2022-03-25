[
  import_deps: [:ecto, :phoenix, :ash, :ash_postgres, :surface],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
