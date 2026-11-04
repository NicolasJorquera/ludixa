#!/usr/bin/env bash
# Compila el App Bundle de producción para Google Play (H8-01).
#
#   bash tool/release.sh           versión de apps/ludixa/pubspec.yaml; exige la
#                                  clave de carga y los IDs de AdMob de producción
#   bash tool/release.sh --local   permite la clave de depuración y sin anuncios:
#                                  solo para revisar el paquete, Play lo rechaza
#
# Deja en build/release/<versión>/ el .aab, el mapa de R8 y los símbolos de
# Dart (código ofuscado). Guardar esa carpeta fuera del repositorio: sin los
# símbolos no se pueden leer los errores de Dart de esa versión.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
app="$root/apps/ludixa"
local=false
[[ "${1:-}" == "--local" ]] && local=true

version=$(sed -n 's/^version: *//p' "$app/pubspec.yaml")
name=${version%+*}
code=${version#*+}
if [[ -z "$name" || "$code" == "$version" ]]; then
  echo "pubspec.yaml debe tener 'version: <nombre>+<código>' (por ejemplo 1.0.0+1)" >&2
  exit 1
fi

missing=()
[[ -f "$app/android/key.properties" ]] || missing+=("android/key.properties (clave de carga, ver README › Firma de versiones)")
[[ -f "$app/android/admob.properties" ]] || missing+=("android/admob.properties (ID de la app en AdMob)")
[[ -f "$app/admob_prod.json" ]] || missing+=("admob_prod.json (bloques de anuncios de producción)")
if [[ ${#missing[@]} -gt 0 ]]; then
  if $local; then
    printf 'Aviso, falta: %s\n' "${missing[@]}" >&2
  else
    printf 'Falta: %s\n' "${missing[@]}" >&2
    echo "Para revisar el paquete sin subirlo: bash tool/release.sh --local" >&2
    exit 1
  fi
fi

out="$root/build/release/$version"
if [[ -e "$out" ]] && ! $local; then
  echo "Ya hay una compilación de $version en build/release: Play rechaza un versionCode repetido." >&2
  echo "Sube el número después del + en apps/ludixa/pubspec.yaml." >&2
  exit 1
fi
rm -rf "$out"
mkdir -p "$out"

defines=()
[[ -f "$app/admob_prod.json" ]] && defines=(--dart-define-from-file=admob_prod.json)

cd "$app"
PUB_HOSTED_URL=https://pub.dev flutter build appbundle --release --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info="$out/simbolos-dart" ${defines[@]+"${defines[@]}"}

cp build/app/outputs/bundle/prodRelease/app-prod-release.aab "$out/ludixa-$version.aab"
cp build/app/outputs/mapping/prodRelease/mapping.txt "$out/mapping.txt"

echo
echo "Ludixa $name (versionCode $code)"
echo "  $out/ludixa-$version.aab"
echo "  $out/mapping.txt      (también va dentro del .aab: Play lo usa solo)"
echo "  $out/simbolos-dart/   (para flutter symbolize; no va a Play)"
$local && echo "  ⚠ Compilación local: no subir a Play."
exit 0
