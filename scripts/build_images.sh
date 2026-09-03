#!/usr/bin/env bash
# Export *.drawio z docs/img/ do PNG v build/img_png/ (zachová podpriečinky vrstiev).
# Ktoré súbory sú zmenené rieši convoj sám; -a mu to prebije cez --force.
#
# Použitie:
#   ./scripts/build_images.sh               # len zmenené súbory
#   ./scripts/build_images.sh -a            # všetky súbory (convoj --force)
#   ./scripts/build_images.sh -f <cesta>    # len tento jeden súbor
#                                           # cesta je relatívna k docs/img,
#                                           # napr. -f 01-Concept/Ext_Int.drawio
#   ./scripts/build_images.sh -a -f <cesta> # jeden súbor, vynútene
#
# Vyžaduje Docker (image rlespinasse/drawio-export).
set -euo pipefail

cd "$(dirname "$0")/.."

# Kontrola, či je dostupný a beží Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "CHYBA: docker nie je nainštalovaný alebo nie je v PATH." >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "CHYBA: Docker daemon nebeží. Spusť Docker Desktop / službu docker a skús znova." >&2
  exit 1
fi


SRC="./docs/img"
OUT="./build/img_png"

mkdir -p "$OUT"

FORCE_ALL=0
ONE_FILE=""

while getopts ":f:a" opt; do
  case "$opt" in
    f)
      # -f je relatívne k SRC (napr. 01-Concept/Ext_Int.drawio).
      # Tolerujeme aj cestu od koreňa repa — prefix SRC/ z nej odstrihneme.
      if [ -e "$SRC/$OPTARG" ]; then
        ONE_FILE="$OPTARG"
      elif [ -e "$OPTARG" ]; then
        ONE_FILE="${OPTARG#"$SRC"/}"
        ONE_FILE="${ONE_FILE#./}"
      else
        echo "CHYBA: '$OPTARG' (-f) neexistuje ani ako $SRC/$OPTARG, ani ako $OPTARG." >&2
        exit 1
      fi
      ;;
    a)
      FORCE_ALL=1
      ;;
    :)
      echo "CHYBA: parameter -$OPTARG vyžaduje cestu." >&2
      exit 1
      ;;
    \?)
      echo "CHYBA: neznámy parameter -$OPTARG" >&2
      echo "Použitie: $0 [-a] [-f <cesta>]" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND - 1))

if [ -n "$ONE_FILE" ]; then
  if [ "$FORCE_ALL" -eq 1 ]; then
    echo "==> vynútený export jedného súboru (-f): convoj ${SRC} ${OUT} --force -f ${ONE_FILE} drawio"
    convoj "$SRC" "$OUT" --force -f "$ONE_FILE" drawio
  else
    echo "==> export jedného súboru (-f): convoj ${SRC} ${OUT} -f ${ONE_FILE} drawio"
    convoj "$SRC" "$OUT" -f "$ONE_FILE" drawio
  fi
else
  if [ "$FORCE_ALL" -eq 1 ]; then
    echo "==> vynútený export všetkých súborov: convoj ${SRC} ${OUT} --force drawio"
    convoj "$SRC" "$OUT" --force drawio
  else
    echo "==> export len zmenených súborov: convoj ${SRC} ${OUT} drawio"
    convoj "$SRC" "$OUT" drawio
  fi
fi

echo "Hotovo. PNG v ${OUT}"
# find "$OUT" -name '*.png' | sort
