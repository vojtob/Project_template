#!/usr/bin/env bash
# Generuje HTML site cez Antora (Docker).
# Výstup: ./build/site/
set -euo pipefail

cd "$(dirname "$0")/.."

docker run --rm -t \
  -v "${PWD}:/antora" \
  antora/antora \
  antora-playbook.yml

echo "Hotovo. Site: ./build/site/index.html"
