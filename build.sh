#!/usr/bin/env bash
# Render both parts to exports/. Re-run after changing any [MEASURE] value.
set -euo pipefail
OSC="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
cd "$(dirname "$0")"
mkdir -p exports
for p in base lid; do
  "$OSC" --backend=manifold -D "part=\"$p\"" -o "exports/ESP32-PowerPack-${p}.stl" case.scad
done
ls -lh exports/
