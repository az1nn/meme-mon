#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-godot}"
GODOT_VERSION="${GODOT_VERSION:-4.7.2}"

actual_version="$("$GODOT_BIN" --version)"
if [[ "$actual_version" != "$GODOT_VERSION".stable* ]]; then
  echo "ERROR: expected Godot ${GODOT_VERSION}.stable; got: ${actual_version}" >&2
  exit 1
fi

mkdir -p web
rm -f web/index.html web/index.js web/index.pck web/index.wasm
"$GODOT_BIN" --headless --path . --import
"$GODOT_BIN" --headless --path . --export-release Web web/index.html
for name in index.html index.js index.wasm index.pck; do
  if [[ ! -s "web/$name" ]]; then
    echo "ERROR: missing/empty Godot web artifact: web/$name" >&2
    exit 1
  fi
done
echo "[mememom] Godot Web export complete"
