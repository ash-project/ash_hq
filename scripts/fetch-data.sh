#!/bin/sh
#
# Runs every fetch script before a build. Each is optional: if one fails, the build carries on
# without that data, and the page that uses it falls back.
#
#     sh scripts/fetch-data.sh

cd "$(dirname "$0")/.."

sh scripts/fetch-contributors.sh || echo "Skipping contributors"
sh scripts/fetch-videos.sh || echo "Skipping videos"
