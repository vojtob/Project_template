#!/usr/bin/env bash
# Generuje PDF cez asciidoctor-pdf (Docker) z manifestu concept_pdf.adoc.
# Výstup: ./build/pdf/Project.pdf
set -euo pipefail

cd "$(dirname "$0")/.."

docker run --rm -t \
  -v "$(pwd):/documents" \
  asciidoctor/docker-asciidoctor \
  asciidoctor-pdf \
  -a imagesdir=images \
  docs/concept/modules/ROOT/concept_pdf.adoc \
  -D build/pdf \
  -o Project.pdf

echo "Hotovo. PDF: ./build/pdf/Project.pdf"
