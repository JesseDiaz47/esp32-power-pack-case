#!/usr/bin/env bash
# Render every part to exports/. Re-run after any params.scad change.
set -euo pipefail
OSC="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
cd "$(dirname "$0")"
mkdir -p exports
echo "building..."
"$OSC" --backend=manifold -D 'PART="plate"' -o exports/ESP32-PowerPack-plate.stl sled.scad 2>&1 \
  | grep -E '^ECHO' | sed 's/ECHO: /  /' || true
"$OSC" --backend=manifold -D 'PART="rail"'  -o exports/ESP32-PowerPack-rail.stl  sled.scad >/dev/null 2>&1
for p in base lid; do
  "$OSC" --backend=manifold -D "part=\"$p\"" -o "exports/ESP32-PowerPack-${p}.stl" case.scad >/dev/null 2>&1
done
rm -f exports/ESP32-PowerPack-sled.stl
echo; ls -lh exports/*.stl | awk '{printf "  %-42s %s\n", $9, $5}'
