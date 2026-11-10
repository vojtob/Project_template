#!/usr/bin/env bash
# Generuje PDF cez asciidoctor-pdf (Docker) z manifestu concept_pdf.adoc.
# Číta zostavenú kópiu build/docs/concept (texty + obrázky), ktorú pripraví
# scripts/build_site.sh alebo scripts/build_all.sh.
# Výstup: ./build/pdf/Project.pdf
set -euo pipefail

cd "$(dirname "$0")/.."

ROOT_DIR="build/docs/concept/modules/ROOT"
MANIFEST="$ROOT_DIR/concept_pdf.adoc"
if [ ! -f "$MANIFEST" ]; then
  echo "CHYBA: $MANIFEST neexistuje. Spusti najprv ./scripts/build_site.sh alebo ./scripts/build_all.sh." >&2
  exit 1
fi

# Kroki server pre grafy a diagramy zapísané textom
bash ./scripts/kroki_start.sh

# asciidoctor-kroki je súčasťou obrazu docker-asciidoctor; diagramy stiahne
# z Kroki servera (kroki-fetch-diagram) a vloží do PDF ako obrázky.
# imagesoutdir: stiahnuté obrázky musia byť v adresári images vedľa manifestu.
docker run --rm -t \
  --network kroki \
  -v "$(pwd):/documents" \
  asciidoctor/docker-asciidoctor \
  asciidoctor-pdf \
  -r asciidoctor-kroki \
  -a kroki-server-url=http://kroki:8000 \
  -a kroki-fetch-diagram \
  -a imagesoutdir="/documents/$ROOT_DIR/images" \
  -a imagesdir=images \
  "$MANIFEST" \
  -D build/pdf \
  -o Project.pdf

echo "Hotovo. PDF: ./build/pdf/Project.pdf"
