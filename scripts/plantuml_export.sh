#!/usr/bin/env bash
# Export všetkých *.puml z docs/img/ do PNG (Docker plantuml/plantuml).
# Výstup: vedľa zdrojov v rovnakom adresári – následne pomocou sync-images.sh.
set -euo pipefail

cd "$(dirname "$0")/.."

SRC="docs/img"

docker run --rm \
  -v "${PWD}/${SRC}:/work" \
  -w /work \
  plantuml/plantuml \
  -tpng -r '**/*.puml'

echo "Hotovo. PNG vedľa zdrojových .puml v ${SRC}/"
echo "Spusti ./scripts/sync-images.sh na presun do modules/ROOT/images/"
