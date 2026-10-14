#!/bin/sh
#
# Runs the site locally, at http://127.0.0.1:1111, with the drafts (like the styleguide), and
# reloading when data/ or highlighting/ change too, which Zola doesn't watch by default and has no
# setting for. Anything else you pass goes on to `zola serve`, like `--port 1112`.
#
#     scripts/serve.sh

set -eu

cd "$(dirname "$0")/.."

exec zola serve --drafts --extra-watch-path data --extra-watch-path highlighting "$@"
