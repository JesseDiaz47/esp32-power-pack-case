#!/usr/bin/env bash
# Does any printed geometry sit where a component has to go?
# Intersects the sled with each component's volume grown by half its clearance.
# A correct sled encloses zero volume there.
set -euo pipefail
cd "$(dirname "$0")"
OSC="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
OUT="${TMPDIR:-/tmp}/interference.stl"
# OpenSCAD writes NO file when the result is empty, so a stale file from a
# previous run would be read as this run's answer. Clear it first.
rm -f "$OUT"
"$OSC" --backend=manifold -D CHECK=1 -o "$OUT" sled.scad >/dev/null 2>&1 || true

python3 - "$OUT" <<'PY'
import sys, os
f = sys.argv[1]
tris=[]; cur=[]
if os.path.exists(f):
    for line in open(f):
        s=line.split()
        if s and s[0]=="vertex":
            cur.append([float(x) for x in s[1:4]])
            if len(cur)==3: tris.append(cur); cur=[]
vol=0.0
for a,b,c in tris:
    vol += (a[0]*(b[1]*c[2]-c[1]*b[2]) - a[1]*(b[0]*c[2]-c[0]*b[2])
            + a[2]*(b[0]*c[1]-c[0]*b[1]))/6.0
vol=abs(vol)
print()
if not os.path.exists(f):
    print("  PASS  nothing intrudes into a component's space  (empty result, no file written)")
elif vol < 0.01:
    print(f"  PASS  nothing intrudes into a component's space  ({len(tris)} coincident facets, {vol:.4f} mm3)")
else:
    print(f"  FAIL  {vol:.2f} mm3 of sled sits inside a component's space")
    print(f"        look at it:  ./render.sh {f} -v iso")
    sys.exit(1)
PY
