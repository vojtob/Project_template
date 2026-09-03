#!/usr/bin/env bash
# Generuje HTML site cez Antora (Docker).
# Výstup: ./build/site/
set -euo pipefail

cd "$(dirname "$0")/.."

echo "teraz som v adresari: $(pwd)"

# copy adoc files to build/docs/concept
SRC="./docs/concept/"
DST="./build/docs/concept/"

mkdir -p "$DST"

rsync -av --delete \
  --prune-empty-dirs \
  --filter="merge scripts/sync-adoc.rules" \
  "$SRC" "$DST"

echo "Skopirované adoc súbory z ${SRC}  ->  ${DST}"

# copy images files to build/docs/concept
SRC="./build/img_png/"
DST="./build/docs/concept/modules/ROOT/images/"

mkdir -p "$DST"

rsync -av --delete \
  --prune-empty-dirs \
  --filter="merge scripts/sync-images.rules" \
  "$SRC" "$DST"

echo "Skopirované obrázky z ${SRC}  ->  ${DST}"

# build site via Docker Antora
echo "Začínam generovať HTML site cez Antora (Docker)..."
docker run --rm -t \
  -v "${PWD}:/antora" \
  antora/antora \
  antora-playbook.yml

echo "Hotovo. Site: ./build/site/index.html"
