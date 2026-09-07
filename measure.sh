#!/usr/bin/env bash
# ---------------------------------------------------------------------------
#  measure.sh -- walk through every real-world dimension in params.scad
#
#    ./measure.sh            all parameters
#    ./measure.sh -q         only the ones that change the print
#    ./measure.sh -l         list current values and where each came from
#
#  Enter accepts the current value. Anything you type is marked measured (M).
#  Values outside a sane range get flagged before they reach the STL.
#  Edits happen in place, so hand-written notes in params.scad survive.
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")"
P=params.scad
MODE=full
case "${1:-}" in
  -q|--quick) MODE=quick ;;
  -l|--list)  MODE=list ;;
  -h|--help)  sed -n '2,12p' "$0"; exit 0 ;;
esac

# VAR | group | critical | min | max | label | where to put the calipers
TABLE='
MOD_L|module|0|40|80|module PCB long edge|Across the long side of the black board, edge to edge. Listing says 56.00.
MOD_W|module|0|25|60|module PCB short edge|Across the short side. Listing says 40.00.
MOD_HX|module|0|30|75|hole spacing, long axis|Centre of one hole to centre of the next, long way. Listing says 48.00.
MOD_HY|module|0|20|55|hole spacing, short axis|Same, short way. Listing says 32.00.
MOD_HD|module|0|2|6|mounting hole diameter|Inside jaws in one hole. The photos third callout said 4.70 - confirm it.
MOD_T|module|1|0.8|3|module PCB thickness|Squeeze the bare board edge where no parts overhang. Usually 1.60.
MOD_UNDER|module|1|0.5|6|solder tails under the module|Board face down on the bench: gap from bench to PCB underside. The longest tail wins.
MOD_OVER|module|1|3|20|tallest part on top of the module|Bench to the top of the USB-A shell. Sets how tall a lid has to be.
CELL_L|cell|1|20|90|cell length|Longest side of the pouch, ignoring the tab and wires.
CELL_W|cell|1|15|60|cell width|Short side of the pouch, ignoring the tab.
CELL_T|cell|1|2|15|cell thickness|Thickest point, usually the middle. Do NOT squeeze - a pouch compresses.
CELL_LEAD|cell|0|20|150|usable JST lead length|Where the wires leave the pouch to the back of the connector.
ESP_L|esp32|1|20|80|ESP32 PCB long edge|Long side, edge to edge, ignoring the USB connector overhang. DevKitC-V4 nominal is 54.40.
ESP_W|esp32|1|15|45|ESP32 PCB short edge|Short side, edge to edge. DevKitC-V4 nominal is 27.90.
ESP_T|esp32|0|0.8|3|ESP32 PCB thickness|Bare board edge. Usually 1.60.
ESP_UNDER|esp32|1|0.5|14|solder tails under the ESP32|Board face down: bench to PCB underside. If male breadboard pins point DOWN this is ~11, not 3.
ESP_OVER|esp32|1|3|25|ESP32 stack height|Bench to the tallest thing on top. Bare board ~6, with headers ~14.
FIT|prefs|0|0.1|1.5|clearance around each board|Per side. 0.50 is snug, 0.80 if your printer runs fat.
SCREW_PILOT|prefs|0|1.5|4|M3 self-tapping pilot|2.50 for PLA/PETG. Go 2.70 if screws split the posts.
SCREW_CLEAR|prefs|0|2.5|5|M3 clearance hole|3.40 lets an M3 pass freely.
'

get()  { grep -E "^$1[[:space:]]*=" "$P" | head -1 | sed -E 's/.*=[[:space:]]*([0-9.]+).*/\1/'; }
sts()  { grep -E "^$1[[:space:]]*=" "$P" | head -1 | sed -E 's|.*//[[:space:]]+([MGD])[[:space:]].*|\1|'; }
num()  { case "$1" in ''|*[!0-9.]*|*.*.*) return 1 ;; *) return 0 ;; esac; }
word() { case "$1" in M) echo "measured" ;; D) echo "datasheet" ;;
                      *) echo "** still a guess **" ;; esac; }
note() { case "$1" in G) printf ', a guess' ;; D) printf ', from a datasheet' ;; esac; }

# rewrite one value and its status char, leaving the rest of the line alone
set_val() {
  T=$(mktemp -t params)
  awk -v var="$1" -v val="$2" -v st="$3" '
    $0 ~ "^"var"[ \t]*=" {
      sub(/=[ \t]*[0-9.]+/, sprintf("= %5.2f", val+0))
      sub(/\/\/[ \t]*[MGD][ \t]+/, "// " st "  ")
    } { print }' "$P" > "$T" && mv "$T" "$P"
}

if [ "$MODE" = list ]; then
  printf "\n  %-12s %8s  %s\n  %s\n" "PARAM" "VALUE" "SOURCE" \
    "------------------------------------------------------------"
  echo "$TABLE" | while IFS='|' read -r v g c lo hi l h; do
    [ -n "$v" ] || continue
    printf "  %-12s %8s  %s\n" "$v" "$(get "$v")" "$(word "$(sts "$v")")"
  done
  echo; exit 0
fi

echo
echo "  Measuring for the ESP32 power pack. Enter keeps the current value."
[ "$MODE" = quick ] && echo "  Quick mode: only the ones that change the print."
echo "  Caliper technique and the LiPo pouch decoder: MEASURING.md"

GROUP=""
while IFS='|' read -r VAR GRP CRIT LO HI LABEL HOW <&3; do
  [ -n "$VAR" ] || continue
  [ "$MODE" = full ] || [ "$CRIT" = 1 ] || continue

  CUR=$(get "$VAR"); ST=$(sts "$VAR")
  case "$ST" in M|D) ;; *) ST=G ;; esac

  [ "$GRP" != "$GROUP" ] && { GROUP="$GRP"; printf '\n  --- %s ---\n' "$GRP"; }
  echo
  echo "  $LABEL   [$VAR]"
  echo "    $HOW"
  while :; do
    printf "    mm (now %s%s): " "$CUR" "$(note "$ST")"
    read -r ANS || ANS=""
    [ -n "$ANS" ] || break
    num "$ANS" || { echo "    '$ANS' is not a number."; continue; }
    if awk -v a="$ANS" -v lo="$LO" -v hi="$HI" 'BEGIN{exit !(a<lo||a>hi)}'; then
      echo "    !! $ANS mm is outside the expected ${LO}-${HI} mm for this."
      printf "    Sure? [y/N] "; read -r OK || OK=""
      case "$OK" in y|Y) ;; *) continue ;; esac
    fi
    set_val "$VAR" "$ANS" M
    break
  done
done 3<<< "$TABLE"

echo; echo "  params.scad updated."
LEFT=$(grep -cE '//[[:space:]]+G[[:space:]]' "$P" || true)
[ "$LEFT" -gt 0 ] && echo "  $LEFT value(s) still a guess - ./measure.sh -l to see which."
echo
printf "  Rebuild the STLs now? [Y/n] "; read -r R || R=""
case "$R" in n|N) echo "  skipped. run ./build.sh when ready." ;; *) ./build.sh && ./check.sh ;; esac
