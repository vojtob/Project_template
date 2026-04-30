#!/usr/bin/env bash
# Sync vygenerovaných PNG do Antora component images/ priečinka.
# Defaultne synchronizuje z ./build/img_png/  ->  docs/concept/modules/ROOT/images/
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="${1:-./build/img_png/}"
DST="${2:-./docs/concept/modules/ROOT/images/}"

mkdir -p "$DST"

rsync -av --delete \
  --prune-empty-dirs \
  --filter="merge scripts/sync-images.rules" \
  "$SRC" "$DST"

echo "Hotovo. ${SRC}  ->  ${DST}"
