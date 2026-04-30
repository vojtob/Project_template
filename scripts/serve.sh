#!/usr/bin/env bash
# Lokálny preview HTML site na http://localhost:8000
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d build/site ]; then
  echo "build/site neexistuje. Spusti najprv ./scripts/build_site.sh"
  exit 1
fi

cd build/site
python3 -m http.server 8000
