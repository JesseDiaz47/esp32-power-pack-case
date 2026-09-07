#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  measure.sh -- walk through every real-world dimension and rewrite params.scad
#
#    ./measure.sh            all parameters
#    ./measure.sh -q         only the 5 that actually change the print
#    ./measure.sh -l         list current values and what's still a guess
#
#  Enter accepts the current value. Anything you type is marked measured (M).
#  Values outside a sane range get flagged before they reach the STL.
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")"
P=params.scad
MODE=full
case "${1:-}" in
  -q|--quick) MODE=quick ;;
  -l|--list)  MODE=list ;;
  -h|--help)  sed -n '2,11p' "$0"; exit 0 ;;
esac

# VAR | group | critical | min | max | label | where to put the calipers
TABLE='
MOD_L|module|0|40|80|module PCB long edge|Across the long side of the black board, edge to edge. Listing says 56.00.
MOD_W|module|0|25|60|module PCB short edge|Across the short side. Listing says 40.00.
MOD_HX|module|0|30|75|hole spacing, long axis|Centre of one hole to centre of the hole beside it, long way. Listing says 48.00.
MOD_HY|module|0|20|55|hole spacing, short axis|Same, short way. Listing says 32.00.
MOD_HD|module|0|2|6|mounting hole diameter|Inside jaws in one hole. The photos third callout said 4.70 - confirm it.
MOD_T|module|1|0.8|3|module PCB thickness|Squeeze the bare board edge where no parts overhang. Usually 1.60.
MOD_UNDER|module|1|0.5|6|solder tails under the module|Board face down on the bench: gap from bench to PCB underside. The longest tail wins.
MOD_OVER|module|1|3|20|tallest part on top of the module|Bench to the very top of the USB-A shell. This sets how tall a lid has to be.
CELL_L|cell|1|20|90|cell length|Longest side of the pouch, ignoring the tab and wires.
CELL_W|cell|1|15|60|cell width|Short side of the pouch, ignoring the tab.
CELL_T|cell|1|2|15|cell thickness|Thickest point, usually the middle. Do NOT squeeze - a pouch compresses.
CELL_LEAD|cell|0|20|150|usable JST lead length|Where the wires leave the pouch to the back of the connector.
ESP_L|esp32|1|20|80|ESP32 PCB long edge|Long side of the board, edge to edge, ignoring the USB connector overhang.
ESP_W|esp32|1|15|45|ESP32 PCB short edge|Short side, edge to edge.
ESP_T|esp32|0|0.8|3|ESP32 PCB thickness|Bare board edge. Usually 1.60.
ESP_UNDER|esp32|0|0.5|8|solder tails under the ESP32|Board face down: bench to PCB underside. Clipped pin stubs count.
ESP_OVER|esp32|1|3|25|ESP32 stack height|Bench to the tallest thing on top. Bare board ~6. With headers fitted ~14.
FIT|prefs|0|0.1|1.5|clearance around each board|Per side. 0.50 is a snug fit, 0.80 if your printer runs fat.
SCREW_PILOT|prefs|0|1.5|4|M3 self-tapping pilot|2.50 for PLA/PETG. Go 2.70 if screws are splitting the posts.
SCREW_CLEAR|prefs|0|2.5|5|M3 clearance hole|3.40 lets an M3 pass freely.
'

get() { grep -E "^$1[[:space:]]*=" "$P" | head -1 | sed -E 's/.*=[[:space:]]*([0-9.]+).*/\1/'; }
sts() { grep -E "^$1[[:space:]]*=" "$P" | head -1 | sed -E 's|.*//[[:space:]]+([MG])[[:space:]].*|\1|'; }
num() { case "$1" in ''|*[!0-9.]*|*.*.*) return 1 ;; *) return 0 ;; esac; }

if [ "$MODE" = list ]; then
  printf "\n  %-12s %8s  %s\n  %s\n" "PARAM" "VALUE" "STATUS" \
    "------------------------------------------------------------"
  echo "$TABLE" | while IFS='|' read -r v g c lo hi l h; do
    [ -n "$v" ] || continue
    printf "  %-12s %8s  %s\n" "$v" "$(get "$v")" \
      "$([ "$(sts "$v")" = M ] && echo 'measured' || echo '** still a guess **')"
  done
  echo; exit 0
fi

echo
echo "  Measuring for the ESP32 power pack. Enter keeps the current value."
[ "$MODE" = quick ] && echo "  Quick mode: only the 5 that change the print."
echo "  Full guide with caliper technique: MEASURING.md"

OUT=$(mktemp -t params); GROUP=""; WGRP=""
{
echo "// ============================================================================"
echo "//  params.scad  --  the only file with real-world measurements in it"
echo "//"
echo "//  Rewritten by ./measure.sh on $(date '+%Y-%m-%d %H:%M')"
echo "//  status:  M = measured with calipers      G = still a guess"
echo "// ============================================================================"
} > "$OUT"

while IFS='|' read -r VAR GRP CRIT LO HI LABEL HOW <&3; do
  [ -n "$VAR" ] || continue
  CUR=$(get "$VAR"); NEW="$CUR"; ST=$(sts "$VAR"); [ "$ST" = M ] || ST=G

  if [ "$MODE" = full ] || [ "$CRIT" = 1 ]; then
    [ "$GRP" != "$GROUP" ] && { GROUP="$GRP"; printf '\n  --- %s ---\n' "$GRP"; }
    echo
    echo "  $LABEL   [$VAR]"
    echo "    $HOW"
    while :; do
      printf "    mm (now %s%s): " "$CUR" "$([ "$ST" = G ] && echo ', a guess')"
      read -r ANS || ANS=""
      [ -n "$ANS" ] || break
      if ! num "$ANS"; then echo "    '$ANS' is not a number."; continue; fi
      if awk -v a="$ANS" -v lo="$LO" -v hi="$HI" 'BEGIN{exit !(a<lo||a>hi)}'; then
        echo "    !! $ANS mm is outside the expected ${LO}-${HI} mm for this."
        printf "    Sure? [y/N] "; read -r OK || OK=""
        case "$OK" in y|Y) ;; *) continue ;; esac
      fi
      NEW="$ANS"; ST=M; break
    done
  fi

  if [ "$GRP" != "$WGRP" ]; then
    WGRP="$GRP"
    printf '\n// --- %s %s\n' "$GRP" \
      "$(printf '%.0s-' $(seq 1 $((66 - ${#GRP}))))" >> "$OUT"
  fi
  printf '%-11s = %6.2f;   // %s  %s\n' "$VAR" "$NEW" "$ST" "$LABEL" >> "$OUT"
done 3<<< "$TABLE"

mv "$OUT" "$P"
echo; echo "  params.scad updated."
LEFT=$(grep -c '//[[:space:]]*G[[:space:]]' "$P" || true)
[ "$LEFT" -gt 0 ] && echo "  $LEFT value(s) still a guess - ./measure.sh -l to see which."
echo
printf "  Rebuild the STLs now? [Y/n] "; read -r R || R=""
case "$R" in n|N) echo "  skipped. run ./build.sh when ready." ;; *) ./build.sh ;; esac
