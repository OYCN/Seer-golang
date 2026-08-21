#!/usr/bin/env bash
# Linux build script for the game server.
# Usage:
#   ./compile.sh            # build -> bin/gameserver
#   ./compile.sh --release  # stripped release build
#   ./compile.sh --watch    # rebuild whenever a .go file changes
#   ./compile.sh --clean    # remove the generated binary

set -euo pipefail

readonly ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly OUT_DIR="$ROOT_DIR/bin"
readonly OUTPUT="$OUT_DIR/gameserver"
readonly PACKAGE="./cmd/gameserver"

release=false
watch=false
clean=false

usage() {
  sed -n '2,7p' "$0" | sed 's/^# //'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -r|--release) release=true ;;
    -w|--watch) watch=true ;;
    -c|--clean) clean=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

build() {
  mkdir -p "$OUT_DIR"
  echo "[$(date '+%H:%M:%S')] Building -> $OUTPUT"
  if [[ "$release" == true ]]; then
    go build -ldflags='-s -w' -o "$OUTPUT" "$PACKAGE"
  else
    go build -o "$OUTPUT" "$PACKAGE"
  fi
  echo "[$(date '+%H:%M:%S')] OK: $OUTPUT"
}

source_hash() {
  find "$ROOT_DIR" -path "$ROOT_DIR/vendor" -prune -o -name '*.go' -print0 \
    | sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | awk '{print $1}'
}

cd "$ROOT_DIR"

if [[ "$clean" == true && -f "$OUTPUT" ]]; then
  rm -f -- "$OUTPUT"
  echo "Removed: $OUTPUT"
fi

if [[ "$watch" == false ]]; then
  if [[ "$clean" == false || "$release" == true ]]; then
    build
  fi
  exit 0
fi

echo "Watch mode: .go changes trigger rebuild (Ctrl+C to stop)"
build
last_hash="$(source_hash)"
while true; do
  sleep 2
  current_hash="$(source_hash)"
  if [[ "$current_hash" != "$last_hash" ]]; then
    build
    last_hash="$current_hash"
  fi
done
