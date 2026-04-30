#!/usr/bin/env bash
# Postupne spustí kompletný pipeline: export diagramov -> sync -> site -> pdf.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> 1/4 Drawio export"
./scripts/drawio_export.sh

echo "==> 2/4 Sync images"
./scripts/sync-images.sh

echo "==> 3/4 Build site"
./scripts/build_site.sh

echo "==> 4/4 Build PDF"
./scripts/build_pdf.sh

echo "Všetko hotové. Site: ./build/site/index.html, PDF: ./build/pdf/Project.pdf"
