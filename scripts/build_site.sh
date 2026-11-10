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

# Rozšírenia Antory (asciidoctor-kroki) podľa package-lock.json. node_modules/ nie je
# v gite, preto sa po klonovaní nainštalujú pri prvom builde (npm z obrazu Antory).
if [ ! -d node_modules/asciidoctor-kroki ]; then
  echo "==> Inštalujem rozšírenia Antory (npm ci)"
  docker run --rm \
    -v "${PWD}:/antora" \
    -w /antora \
    --entrypoint npm \
    antora/antora \
    ci --no-fund --no-audit
fi

# Kroki server pre grafy a diagramy zapísané textom (rozšírenie asciidoctor-kroki)
bash ./scripts/kroki_start.sh

# build site via Docker Antora
echo "Začínam generovať HTML site cez Antora (Docker)..."
# CI=true: UI pri lokálnom builde nezobrazí odkaz „Edit this Page“ (file:// cesta v kontajneri)
# --network kroki: Antora dosiahne Kroki server na http://kroki:8000
docker run --rm -t \
  -e CI=true \
  --network kroki \
  -v "${PWD}:/antora" \
  antora/antora \
  antora-playbook.yml

echo "Hotovo. Site: ./build/site/index.html"
