#!/bin/sh
#
# Builds data/doc-modules.json: every module and mix task in the libraries in data/libraries.txt,
# from their docs on hexdocs.pm, for redirecting the old ash-hq.org docs URLs
# (netlify/edge-functions/docs-redirect.js). The file is committed; rerun this if old links to a
# library added since stop resolving.
#
#     scripts/fetch-doc-modules.sh
#
# Each module is listed by its name ("Ash.Resource") and by the lowercased, dashed form the old
# site used in URLs ("ash-resource"); each mix task by its name ("ash.codegen") and that form too.
# Needs curl and jq.

set -eu

cd "$(dirname "$0")/.."

output=data/doc-modules.json
sidebars=$(mktemp -d)
trap 'rm -rf "$sidebars"' EXIT

grep -v -e '^#' -e '^$' data/libraries.txt | while read -r repo; do
  package=${repo#*/}

  # The sidebar file's name has a hash in it, so find it from the docs' main page
  page=$(curl -fsSL "https://hexdocs.pm/$package/readme.html" 2>/dev/null || curl -fsSL "https://hexdocs.pm/$package/api-reference.html")
  sidebar=$(printf '%s' "$page" | grep -o 'dist/sidebar_items-[A-Za-z0-9]*\.js' | head -1)

  # It assigns the data to a variable: `sidebarNodes={…}`
  curl -fsSL "https://hexdocs.pm/$package/$sidebar" | sed 's/^sidebarNodes=//' |
    jq --arg package "$package" '{package: $package, modules: [.modules[]?.id], tasks: [.tasks[]? | {id, name: (.title | sub("^mix "; ""))}]}' \
    > "$sidebars/$package.json"
done

# {key: "package/Module"}, the first package listing a key winning
jq -s '
  def sanitize: ascii_downcase | gsub("[^a-z0-9_]"; "-");
  [ .[] | .package as $package
    | (.modules[] | {(.): "\($package)/\(.)"}, {(sanitize): "\($package)/\(.)"}),
      (.tasks[] | {(.name): "\($package)/\(.id)"}, {(.name | sanitize): "\($package)/\(.id)"}, {(.id): "\($package)/\(.id)"})
  ]
  | reverse | add
' "$sidebars"/*.json > "$output"

echo "Wrote $(jq length "$output") names to $output"
