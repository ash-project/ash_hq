#!/bin/sh
#
# Fetches everyone who has contributed to the repositories in data/contributor-repos.txt, for the
# Community page, and writes them to data/contributors.json. Run before `zola build`; the
# scheduled rebuilds keep the list current.
#
#     scripts/fetch-contributors.sh
#
# Needs curl and jq. Set GITHUB_TOKEN to raise GitHub's rate limit from 60 requests an hour to
# 5,000: a full run makes about 45.

set -eu

cd "$(dirname "$0")/.."

repos=data/contributor-repos.txt
output=data/contributors.json
pages=$(mktemp -d)
trap 'rm -rf "$pages"' EXIT

auth=""
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth="Authorization: Bearer $GITHUB_TOKEN"
fi

n=0
grep -v -e '^#' -e '^$' "$repos" | while read -r repo; do
  page=1
  while :; do
    n=$((n + 1))
    file="$pages/$(printf '%04d' "$n").json"
    curl -fsS ${auth:+-H "$auth"} -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$repo/contributors?per_page=100&page=$page" > "$file"

    # A short page is the last one
    [ "$(jq length "$file")" -lt 100 ] && break
    page=$((page + 1))
  done
done

# Everyone once, in the order they were first found, without bots
jq -s '
  add
  | map(select(.type == "User"))
  | reduce .[] as $c ([]; if any(.[]; .id == $c.id) then . else . + [$c] end)
  | map({login, avatar_url, html_url})
' "$pages"/*.json > "$output"

echo "Wrote $(jq length "$output") contributors to $output"
