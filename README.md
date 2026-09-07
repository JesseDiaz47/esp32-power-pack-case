# ESP32 Power Pack Case

Mounts the **NULLLAB LiPo module** (1200 mAh, USB‑C in, USB‑A + 3V3/5V out,
4‑LED gauge), its **LiPo pouch cell**, and an **ESP32‑WROOM‑32 DevKitC‑V4**
(38‑pin, 54.4 × 27.9 mm) — the same board as `~/Code/quadruped-r1`.

Two parts, printed in this order on purpose:

| | what it is | size (mm) | why |
|---|---|---|---|
| **`sled.scad`** | open plate, no walls, no lid | 70 × 124 × 3 | **Print this first.** No ports means nothing can be wrong about port positions. It proves the numbers. |
| **`case.scad`** | enclosed tray + lid | 72.8 × 117.8 × 19.4 | Print once the sled says the numbers are right. |

All three STLs render manifold. `exports/` is current.

---

## Start here

```bash
./measure.sh -q      # the 5 numbers that change the print
./build.sh           # re-render every STL
```

Then print `exports/ESP32-PowerPack-sled.stl`, bolt the three parts down, and
find out what's wrong before committing to an enclosure.

Read [MEASURING.md](MEASURING.md) first — it has the caliper technique for the
awkward measurements, and the trick that gets the cell size without calipers at
all (the 6-digit number on a LiPo pouch *is* its dimensions: `503450` = 5.0 ×
34 × 50 mm).

---

## Files

| | |
|---|---|
| `params.scad` | **The only file with real-world measurements in it.** Everything else derives from it. Each value is tagged `M` measured / `D` datasheet / `G` guess. |
| `sled.scad` | Option D, the open fit-test plate |
| `case.scad` | the enclosed tray + lid |
| `measure.sh` | walks you through each dimension, validates the range, rewrites `params.scad` |
| `render.sh` | preview PNGs from any `.scad` **or `.stl`** |
| `build.sh` | renders every part to `exports/` |
| `check.sh` | interference test — does any printed geometry sit where a component has to go? |
| `MEASURING.md` | how to get the numbers |

### `measure.sh`

```bash
./measure.sh          # everything
./measure.sh -q       # only the 5 that matter
./measure.sh -l       # what's still a guess
```

Enter keeps the current value. Anything you type gets marked `M` (measured);
`D` means sourced from a datasheet, `G` means still a guess. Edits are made in
place, so hand-written notes in `params.scad` survive a run. Each parameter has a sane
range — type a cell thickness of 50 mm and it stops you rather than silently
producing a 54 mm tall clip.

### `render.sh`

Works on anything, including STLs you downloaded from Makerworld:

```bash
./render.sh sled.scad                      # iso, top, front, right
./render.sh exports/anything.stl -v all    # all 7 views
./render.sh sled.scad -t 24                # 24-frame turntable
./render.sh sled.scad -s 2400x1800 -c Monotone
```

Schemes: `Tomorrow Cornfield DeepOcean Starnight Nature BeforeDawn Monotone`.
An STL gets wrapped in a throwaway `.scad` so OpenSCAD can frame a camera on it.

### `check.sh`

Intersects the sled with each component's volume, grown by half its nominal
clearance. A correct part encloses **zero volume** there.

```bash
./check.sh      # PASS / FAIL
```

This caught a real bug: the corner brackets were being built *inside* each
pocket instead of outside it, shrinking every pocket by 3.2 mm in both axes.
The ESP32 and the cell would not have dropped in.

What it can and can't do:

- **Catches** geometry that collides with a component — brackets on the wrong
  side, a standoff reaching into the next bay, a zip-tie slot cutting a
  bracket's base.
- **Cannot catch a wrong measurement.** The pockets derive from `params.scad`,
  so if a number is wrong the pocket is wrong *and consistent*, and the check
  passes happily. Only a real dry fit finds those.

---

## The sled

```
  .-------------------------.
  | o  ESP32 54.4 x 27.9 o  |   corner brackets + one zip tie
  |                         |
  | ==   cell  50 x 34   == |   corner brackets + two zip ties
  |                         |
  | o   module 56 x 40   o  |   four M3 screws on the 48 x 32 pattern
  '-------------------------'
     o = mounting hole through the plate
```

Plate 70 × 124 × 3 mm. Tallest printed feature 10 mm. Assembled envelope
70 × 124 × 17.1 mm. Bay labels are engraved so the dry fit is unambiguous.

Prints flat, no supports, ~1/3 the filament of the enclosed case.

**Hardware:** 4 × M3 × 8 self-tapping (module → standoffs), 3–5 zip ties,
optionally 4 × M3 through the corner holes to bolt the sled to something.

---

## What's still a guess

`./measure.sh -l` is authoritative.

**Solid:** the module footprint (56 × 40, 48 × 32 hole pattern), straight off
the listing photo.

**Datasheet, not calipers:** the ESP32 footprint, 54.4 × 27.9 mm. That is the
Espressif DevKitC‑32E nominal, matching row 17 of
`~/Code/quadruped-r1/controller/docs/MEASUREMENTS.md`.

> **Note for the ESP32 Cyberdeck Case project:** it builds its pocket around
> 51 × 28 mm for what it calls the same 38‑pin board. A real 38‑pin DevKitC is
> 54.4 mm long. That pocket is likely 3.4 mm short.

**Still guesses:** every Z dimension, and the entire cell size.

`ESP_UNDER` is the one to watch. It assumes 3 mm of solder tail. If your
DevKitC has male breadboard pins pointing **down**, the real figure is nearer
11 mm and the ESP32 brackets are wrong — tell `measure.sh` and it rebuilds.

The enclosed case additionally guesses **port positions**, scaled off the
listing photo at 7.4 px/mm, so ±1.5 mm. Two consequences already baked in:

- USB‑C and the ON/OFF switch are ~12 mm apart, which would leave a 0.9 mm rib
  between two cutouts — too thin to print. They share **one port window**.
- The USB‑A is cut **edge‑facing**. If yours points up, that cutout moves to
  the lid.

Neither applies to the sled. That's the point of the sled.

---

## Before trusting the enclosed case

1. Print the sled. Dry-fit all three parts. Fix `params.scad`.
2. Confirm USB‑C **cable body** clearance, not just the connector.
3. Confirm the cell's JST lead reaches the module's back-edge connector —
   it's ~45 mm of routing.
4. Confirm the USB‑A is edge-facing, not vertical.
5. Print the base alone before committing to the lid.
