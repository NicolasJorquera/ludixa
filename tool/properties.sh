#!/usr/bin/env bash
# Corre la suite de propiedades de un paquete compilada AOT e imprime su
# informe en Markdown. La usan la CI de cada PR y el workflow nocturno.
#
# Uso (desde packages/<paquete>): bash ../../tool/properties.sh <paquete> <semillas> <salt> <días>
#   <semillas>  puzzles por nivel en los motores
#   <salt>      prefijo de las semillas; cambiarlo explora puzzles nuevos
#   <días>      días seguidos del reto diario que se generan
set -euo pipefail

package="$1" count="$2" salt="$3" days="$4"
mkdir -p build
if [ "$package" = daily_challenge ]; then
  dart compile exe tool/check_days.dart -o build/properties >/dev/null
  build/properties --from 2026-11-02 --days "$days"
else
  dart compile exe tool/benchmark.dart -o build/properties >/dev/null
  build/properties --count "$count" --salt "$salt" --verify
fi
