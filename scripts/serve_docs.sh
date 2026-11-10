#!/usr/bin/env bash
# Lokálny náhľad HTML site na http://localhost:8001
# (port 8000 používa Kroki server, pozri scripts/kroki_start.sh)
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d build/site ]; then
  echo "build/site neexistuje. Spusti najprv ./scripts/build_site.sh alebo ./scripts/build_all.sh" >&2
  exit 1
fi

cd build/site
python3 -m http.server 8001
