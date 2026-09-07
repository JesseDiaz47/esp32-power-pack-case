# Finding the dimensions

Ten numbers stand between this and a part that fits. Five of them change the
print. Run `./measure.sh -q` for just those, or `./measure.sh` for all of them.
`./measure.sh -l` tells you what's still a guess.

---

## The trick: LiPo pouches print their own size

The cell is the biggest unknown here, and you probably don't need calipers for
it at all. Almost every pouch cell has a 6-digit number printed on the wrapper.
**That number is the dimensions.**

```
        5 0 3 4 5 0
        ├─┘ ├─┘ ├─┘
         │   │   └── length  in mm          = 50
         │   └────── width   in mm          = 34
         └────────── thickness in 0.1 mm    = 5.0
```

So `503450` is a 5.0 × 34 × 50 mm pouch. That is exactly the assumption baked
into `params.scad` right now.

Other examples: `603048` → 6.0 × 30 × 48. `803860` → 8.0 × 38 × 60.

Seven digits means a dimension went over 99 mm — `8040120` → 8.0 × 40 × 120.

Two cautions:
- The number is the **bare cell**. Protection circuits, wrapper and the tab at
  the wire end add roughly 1–2 mm to the length. `params.scad` already carries
  1 mm of slack, but measure the real thing before printing an enclosed case.
- Cells are routinely 0.3–0.8 mm fatter than the number claims. Never build a
  pocket with zero clearance on `CELL_T`.

---

## Caliper technique for the three awkward ones

**`MOD_OVER` — tallest part on the module.**
Lay the board flat on the bench. Use the depth rod out the end of the calipers,
or the step on the back of the jaws, and go from bench surface to the top of the
USB-A shell. Measuring the connector alone and adding `MOD_T` works too, and is
easier to get square.

**`MOD_UNDER` / `ESP_UNDER` — solder tails.**
Board *face down* on the bench. Measure bench to PCB underside. You want the
single longest tail, not the average — that one tail is what holds the board off
its standoffs and throws every height above it.

**`CELL_T` — pouch thickness.**
Close the jaws until they *just* kiss the pouch, then stop. A pouch compresses,
so leaning on the calipers will read 0.5 mm under and you'll design a pocket the
cell won't sit flat in. Measure the fattest point, usually the middle.

---

## No calipers? No part yet?

**For the sled, a steel rule is fine.** It has no walls and no port cutouts, so
nothing has to line up with a connector — ±0.5 mm changes nothing that matters.
That's the whole reason to print the sled first.

**For the enclosed case you need real numbers**, because the cutouts have to
meet connectors. Ways to get them without the part in hand:

- The listing's "Product information" table and the Q&A section — sellers post
  thickness there more often than in the description.
- The seller's other photos. One of them usually has a ruler or a coin in frame.
- Scale off a photo against a known dimension. That's how the port positions in
  `case.scad` were derived: the module is 56 mm wide, the photo was 7.4 px/mm,
  so everything else could be measured in pixels and divided. Good to about
  ±1.5 mm — fine for sizing a bay, not fine for a USB-C cutout.

---

## Order to do this in

1. `./measure.sh -q`, using the pouch number for the cell.
2. `./build.sh`, print `exports/ESP32-PowerPack-sled.stl`.
3. Bolt all three parts down. Note anything that fought you.
4. Fix those numbers, then move to the enclosed case.
