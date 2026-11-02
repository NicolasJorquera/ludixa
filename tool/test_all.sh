#!/usr/bin/env bash
# Ejecuta las pruebas de cada miembro del workspace con la herramienta que le
# corresponde: `flutter test` si depende de Flutter, `dart test` si es Dart puro.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
members=$(sed -n '/^workspace:/,/^[^ ]/p' "$root/pubspec.yaml" | sed -n 's/^  - //p')

status=0
for member in $members; do
  dir="$root/$member"
  if [ ! -d "$dir/test" ]; then
    echo "::error::$member no tiene pruebas (test/)"
    status=1
    continue
  fi
  echo "── $member"
  if grep -q "sdk: flutter" "$dir/pubspec.yaml"; then
    (cd "$dir" && flutter test) || status=1
  else
    (cd "$dir" && dart test) || status=1
  fi
done
exit $status
