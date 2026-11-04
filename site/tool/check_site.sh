#!/usr/bin/env bash
# Antes de publicar el sitio: no deben quedar marcas por completar ([[...]])
# ni el ID de editor de ejemplo en app-ads.txt.
set -euo pipefail
public="$(cd "$(dirname "$0")/../public" && pwd)"
status=0
if grep -n '\[\[' "$public"/*.html; then
  echo "Quedan marcas [[...]] por completar (algunas las define Legal/Administración)." >&2
  status=1
fi
if grep -q 'pub-0000000000000000' "$public/app-ads.txt"; then
  echo "app-ads.txt tiene el ID de editor de ejemplo: poner el de AdMob (Cuenta › Información de la cuenta)." >&2
  status=1
fi
exit $status
