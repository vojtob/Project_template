#!/usr/bin/env bash
# Export všetkých *.drawio z docs/img/ do PNG (Docker rlespinasse/drawio-export).
# Výstup: ./build/img_png/<rovnaká cesta ako v docs/img/>
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="docs/img"
DST="build/img_png"
mkdir -p "$DST"

docker run --rm \
  -v "${PWD}/${SRC}:/data" \
  -v "${PWD}/${DST}:/output" \
  rlespinasse/drawio-export \
  --format png \
  --transparent \
  --output /output \
  /data

echo "Hotovo. Exportované PNG: ./${DST}/"
echo "Spusti ./scripts/sync-images.sh na presun do modules/ROOT/images/"
