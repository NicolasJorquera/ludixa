#!/usr/bin/env bash
# Genera las imágenes de la marca y de la ficha de Play con Chrome sin interfaz
# (perfil temporal: no toca el Chrome del usuario):
#   docs/ficha/icono-512.png                 icono para Play (cuadrado; Play lo redondea)
#   docs/ficha/grafico-destacado-{es,en}.png gráfico destacado de 1024 × 500
#   apps/ludixa/android/.../mipmap-*/ic_launcher.png  icono para Android 7.0–7.1
# Fuente: docs/ficha/fuente/. El icono adaptable (Android 8+) es vectorial y no
# se genera aquí: drawable/ic_launcher_foreground.xml usa las mismas medidas.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/docs/ficha/fuente"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
profile=$(mktemp -d)
trap 'rm -rf "$profile"' EXIT

shot() { # url, ancho, alto, salida
  "$chrome" --headless=new --disable-gpu --hide-scrollbars --user-data-dir="$profile" \
    --default-background-color=00000000 --virtual-time-budget=3000 \
    --window-size="$2,$3" --screenshot="$4" "$1" >/dev/null 2>&1
  echo "  $4"
}

shot "file://$src/lienzo.html?src=icono-visible.svg&forma=cuadrado" 512 512 "$root/docs/ficha/icono-512.png"
for idioma in es en; do
  shot "file://$src/grafico-destacado.html?idioma=$idioma" 1024 500 "$root/docs/ficha/grafico-destacado-$idioma.png"
done

res="$root/apps/ludixa/android/app/src/main/res"
tmp="$profile/ic_launcher.png"
# Chrome sin interfaz no baja de cierto ancho de ventana: se renderiza a 512 y se reduce.
shot "file://$src/lienzo.html?src=icono-visible.svg&forma=redondeado" 512 512 "$tmp"
for pair in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  sips --resampleHeightWidth "${pair#*:}" "${pair#*:}" "$tmp" --out "$res/mipmap-${pair%%:*}/ic_launcher.png" >/dev/null
  echo "  mipmap-${pair%%:*}/ic_launcher.png"
done
