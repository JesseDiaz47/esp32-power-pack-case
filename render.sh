#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  render.sh -- turn any .scad or .stl into preview PNGs
#
#    ./render.sh sled.scad                    4 standard views
#    ./render.sh exports/whatever.stl         works on downloaded STLs too
#    ./render.sh sled.scad -v iso -s 2400x1800
#    ./render.sh sled.scad -t 24              24-frame turntable
#
#  Views: iso, top, bottom, front, back, left, right, all
#  Schemes: Tomorrow Cornfield DeepOcean Starnight Nature BeforeDawn Monotone
# ---------------------------------------------------------------------------
set -euo pipefail
OSC="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
[ -x "$OSC" ] || { echo "OpenSCAD not found at $OSC"; exit 1; }

IN=""; VIEWS="iso top front right"; SIZE="1600x1200"; SCHEME="Tomorrow"
OUT="renders"; TURN=0

while [ $# -gt 0 ]; do
  case "$1" in
    -v|--view)   VIEWS="$2"; shift 2 ;;
    -s|--size)   SIZE="$2"; shift 2 ;;
    -c|--scheme) SCHEME="$2"; shift 2 ;;
    -o|--out)    OUT="$2"; shift 2 ;;
    -t|--turn)   TURN="$2"; shift 2 ;;
    -h|--help)   sed -n '2,16p' "$0"; exit 0 ;;
    *)           IN="$1"; shift ;;
  esac
done
[ -n "$IN" ] || { sed -n '2,16p' "$0"; exit 1; }
[ -f "$IN" ] || { echo "no such file: $IN"; exit 1; }

# camera rotations: rotx roty rotz
cam() { case "$1" in
  iso)    echo "55 0 25"  ;;  top)   echo "0 0 0"    ;;  bottom) echo "180 0 0" ;;
  front)  echo "90 0 0"   ;;  back)  echo "90 0 180" ;;  left)   echo "90 0 270" ;;
  right)  echo "90 0 90"  ;;  *)     echo "" ;;
esac; }

mkdir -p "$OUT"
BASE="$(basename "${IN%.*}")"
SRC="$IN"

# an STL gets wrapped in a throwaway .scad so OpenSCAD can camera it
if [ "${IN##*.}" = "stl" ] || [ "${IN##*.}" = "STL" ]; then
  SRC="$(mktemp -t stlview).scad"
  printf 'import("%s");\n' "$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")" > "$SRC"
  trap 'rm -f "$SRC"' EXIT
fi

shoot() { # $1=name $2..$4=rot
  "$OSC" --backend=manifold --viewall --autocenter \
         --colorscheme="$SCHEME" --imgsize="${SIZE/x/,}" \
         --camera="0,0,0,$2,$3,$4,0" \
         -o "$OUT/${BASE}-$1.png" "$SRC" >/dev/null 2>&1
  echo "  $OUT/${BASE}-$1.png"
}

if [ "$TURN" -gt 0 ]; then
  echo "turntable, $TURN frames:"
  for i in $(seq 0 $((TURN-1))); do
    z=$(( 360 * i / TURN ))
    shoot "$(printf 'turn%03d' "$i")" 60 0 "$z"
  done
  command -v ffmpeg >/dev/null && echo "  -> ffmpeg -i $OUT/$BASE-turn%03d.png $BASE.gif"
else
  [ "$VIEWS" = "all" ] && VIEWS="iso top bottom front back left right"
  echo "rendering $BASE:"
  for v in $VIEWS; do
    r="$(cam "$v")"; [ -n "$r" ] || { echo "  unknown view: $v"; continue; }
    shoot "$v" $r
  done
fi
