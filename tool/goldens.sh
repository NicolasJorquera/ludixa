#!/usr/bin/env bash
# Corre las pruebas golden en Linux x86_64, como la CI, y copia los
# resultados al repositorio. Los goldens se generan siempre aquí: el
# renderizado de fuentes de macOS no coincide con el de Linux.
#
#   bash tool/goldens.sh            verifica (deja las diferencias en test/failures)
#   bash tool/goldens.sh --update   regenera los goldens
#   bash tool/goldens.sh --update apps/ludixa test/golden_matrix_test.dart
#                                   solo un paquete (y, si se quiere, un archivo)
#
# Necesita Docker. El SDK de Flutter y la caché de pub quedan en volúmenes
# (ludixa-flutter, ludixa-pub) para no descargarlos cada vez.
set -euo pipefail

FLUTTER_VERSION=3.41.4
root=$(cd "$(dirname "$0")/.." && pwd)
update=""
if [[ "${1:-}" == "--update" ]]; then
  update="--update-goldens"
  shift
fi
only_package="${1:-}"
only_file="${2:-}"

docker run --rm --platform linux/amd64 \
  -v "$root":/src \
  -v ludixa-flutter:/flutter \
  -v ludixa-pub:/root/.pub-cache \
  -e PUB_HOSTED_URL=https://pub.dev \
  -e UPDATE="$update" -e ONLY_PACKAGE="$only_package" -e ONLY_FILE="$only_file" \
  -e FLUTTER_VERSION="$FLUTTER_VERSION" \
  ubuntu:24.04 bash -euo pipefail -c '
    export DEBIAN_FRONTEND=noninteractive PATH=/flutter/bin:$PATH
    if ! command -v git >/dev/null; then
      apt-get update -qq && apt-get install -y -qq git curl unzip xz-utils ca-certificates >/dev/null
    fi
    if [[ ! -x /flutter/bin/flutter ]]; then
      git clone -q --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git /flutter
    fi
    git config --global --add safe.directory "*"
    flutter --version --suppress-analytics

    # Copia de trabajo: así .dart_tool y los lockfiles de Linux no pisan los de macOS.
    mkdir /work
    git -C /src ls-files -co --exclude-standard | tar -C /src -cf - -T - | tar -C /work -xf -
    cd /work
    flutter pub get --suppress-analytics >/dev/null

    status=0
    for dir in apps/ludixa packages/*; do
      grep -rqs "group(.goldens., skip: goldensSkip" "$dir/test" || continue
      [[ -z "$ONLY_PACKAGE" || "$dir" == "$ONLY_PACKAGE" ]] || continue
      echo "== $dir"
      (cd "$dir" && flutter test --suppress-analytics --name "^goldens " $UPDATE ${ONLY_FILE:-}) || status=1
      rm -rf "/src/$dir/test/failures"
      if [[ -d "$dir/test/failures" ]]; then cp -r "$dir/test/failures" "/src/$dir/test/"; fi
      if [[ -n "$UPDATE" ]]; then
        rm -rf "/src/$dir/test/goldens"
        cp -r "$dir/test/goldens" "/src/$dir/test/"
      fi
    done
    exit $status
  '
