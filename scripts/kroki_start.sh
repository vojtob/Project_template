#!/usr/bin/env bash
# Zabezpečí, že beží lokálny Kroki server: kontajner "kroki" v Docker sieti "kroki".
# Antora a asciidoctor-pdf (tiež v Dockeri) ho volajú na http://kroki:8000 a generujú
# z neho grafy a diagramy zapísané textom v .adoc (napr. [vegalite], [plantuml]).
# Zdroje diagramov tak neopúšťajú počítač. Port 8000 je publikovaný len na 127.0.0.1.
#
# Zastavenie: docker stop kroki    Odstránenie: docker rm -f kroki && docker network rm kroki
set -euo pipefail

NET=kroki
NAME=kroki
IMAGE=yuzutech/kroki

docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET" >/dev/null

if ! docker container inspect "$NAME" >/dev/null 2>&1; then
  echo "==> Spúšťam Kroki server ($IMAGE)"
  docker run -d --name "$NAME" --network "$NET" -p 127.0.0.1:8000:8000 "$IMAGE" >/dev/null
elif [ "$(docker container inspect -f '{{.State.Running}}' "$NAME")" != "true" ]; then
  echo "==> Štartujem zastavený Kroki server"
  docker start "$NAME" >/dev/null
fi

for _ in $(seq 1 30); do
  if curl -sf http://127.0.0.1:8000/health >/dev/null; then
    echo "Kroki beží (http://127.0.0.1:8000)"
    exit 0
  fi
  sleep 1
done

echo "CHYBA: Kroki server neodpovedá na http://127.0.0.1:8000/health" >&2
exit 1
