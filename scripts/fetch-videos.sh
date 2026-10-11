#!/bin/sh
#
# Fetches the videos in the YouTube playlist named in data/media.toml, for the Media page, and
# writes them to data/videos.json, newest first. Run before `zola build`; the scheduled rebuilds keep the list
# current. Without it, the page embeds the playlist instead.
#
#     YOUTUBE_API_KEY=… sh scripts/fetch-videos.sh
#
# Needs curl, jq and a YouTube Data API key (see DEVELOPING.md). Each run uses one unit of the
# key's free daily quota of 10,000 for every 50 videos.

set -eu

cd "$(dirname "$0")/.."

if [ -z "${YOUTUBE_API_KEY:-}" ]; then
  echo "YOUTUBE_API_KEY isn't set" >&2
  exit 1
fi

playlist=$(sed -n 's/^youtube_playlist = "\(.*\)"$/\1/p' data/media.toml)
output=data/videos.json
pages=$(mktemp -d)
trap 'rm -rf "$pages"' EXIT

# The key goes in a header, not the URL, so it can't turn up in error messages or logs
n=0
token=""
while :; do
  n=$((n + 1))
  file="$pages/$(printf '%04d' "$n").json"
  curl -fsS -G -H "X-Goog-Api-Key: $YOUTUBE_API_KEY" \
    -d part=snippet,status,contentDetails -d maxResults=50 -d "playlistId=$playlist" ${token:+-d "pageToken=$token"} \
    "https://www.googleapis.com/youtube/v3/playlistItems" > "$file"

  token=$(jq -r '.nextPageToken // empty' "$file")
  [ -z "$token" ] && break
done

# Newest first, by when each video was uploaded (not added to the playlist), leaving out private
# and deleted videos
jq -s '
  map(.items) | add
  | map(select(.status.privacyStatus == "public" or .status.privacyStatus == "unlisted"))
  | map({
      id: .snippet.resourceId.videoId,
      title: .snippet.title,
      published: .contentDetails.videoPublishedAt,
      thumbnail: .snippet.thumbnails.high.url
    })
  | sort_by(.published) | reverse
' "$pages"/*.json > "$output"

echo "Wrote $(jq length "$output") videos to $output"
