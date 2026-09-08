# ESP32 Power Pack Case

Mounts the **NULLLAB LiPo module** (1200 mAh, USB‑C in, USB‑A + 3V3/5V out,
4‑LED gauge), its **LiPo pouch cell**, and an **ESP32‑WROOM‑32 DevKitC‑V4**
(38‑pin, 54.4 × 27.9 mm) — the same board as `~/Code/quadruped-r1`.

Two parts, printed in this order on purpose:

| | what it is | size (mm) | why |
|---|---|---|---|
| **`sled.scad`** | open plate + 2 bolt-on rails | 76 × 129.9 × 3 | **Print this first.** No ports means nothing can be wrong about port positions. It proves the numbers. |
| **`case.scad`** | enclosed tray + lid | 72.8 × 117.8 × 19.4 | Print once the sled says the numbers are right. |

All three STLs render manifold. `exports/` is current.

---

## Printed — 2026-09-07

![The printed case, closed](photos/01-case-closed-port-window.jpg)

| photo | |
|---|---|
| [01](photos/01-case-closed-port-window.jpg) | closed — the shared USB‑C + ON/OFF port window |
| [02](photos/02-case-closed-lid-vents.jpg) | lid on — vents, LED gauge window, board visible through the slots |
| [03](photos/03-open-lid-and-tray.jpg) · [04](photos/04-open-tray-populated.jpg) | open and populated |
| [05](photos/05-esp32-devkitc-board.jpg) | the DevKitC — underside is flat, no downward pins (confirms `ESP_UNDER`) |
| [06](photos/06-lipo-module-with-cell.jpg) | the module with its cell — stamped `JBC 103040PL` |

**The case printed fine. The cell did not fit the bay built for it.**

The one number this README flagged as a pure guess is the one that bit.
`params.scad` assumed a `503450` pouch — 5.5 × 34 × 50 mm. The real cell is
stamped **`103040`**: **10.0 × 30 × 40 mm**. Wrong in all three axes, and
nearly twice the assumed thickness.

So the middle bay sits empty and the cell rides on top of the module — that is
the layout in photos 03–04, not what `case.scad` renders.

`params.scad` now carries the real cell. **The geometry has not been rebuilt
around it yet**, so `exports/` and `renders/` still show the three-bay layout.

> `case.scad` does **not** `include <params.scad>` — it keeps its own copy of
> every dimension, still carrying the old cell numbers and `ESP_L = 51.0`. Only
> `sled.scad` reads `params.scad`. Fixing that is the next job.

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

Black hex-lightened deck, burnt-orange bolt-on side rails, screws left showing —
the same direction the ESP32 Cyberdeck Case concept already approved.

```
  #===========================#
  #|  o   module 56 x 40  o  |#   four M3 on the 48 x 32 pattern
  #|      hex cut through     |#
  #|-------------------------|#
  #|      cell 50 x 34        |#   brackets + two zip ties
  #|      hex ENGRAVED only   |#
  #|-------------------------|#
  #|  ESP32 54.4 x 27.9      |#   brackets + one zip tie
  #|      hex cut through     |#
  #===========================#
     # = orange rail, 3 exposed M3 a side
```

| part | size (mm) | qty | colour |
|---|---|---|---|
| plate | 76 × 129.9 × 3 | 1 | black |
| rail | 8 × 129.9 × 3.5 | **2** | burnt orange |

Tallest feature 10 mm. Assembled envelope 76 × 129.9 × 17.1 mm.

**Three deliberate choices:**

- **Chamfers, 1 mm top and bottom.** More than anything else, a chamfered edge
  is what stops a part reading as 3D printed. It also kills elephant's foot.
- **Only whole hexes are placed.** A hex is drawn solely if the entire cell
  clears the zone and every feature. Clipping a hex field against keepouts
  instead leaves half-eaten slivers, which read as damage.
- **The cell bay is engraved, not cut.** A pouch cell needs continuous support,
  so it gets the same grid 0.6 mm deep. The panel stays one system without
  putting holes under the battery.

Prints flat, no supports — every overhang is a 45° chamfer or steeper.

**Hardware:** 4 × M3 × 8 self-tapping (module → standoffs), 6 × M3 × 8
self-tapping (rails → plate, countersunk), 3 zip ties. If you'd rather bolt the
whole sled to something, open the plate's six holes to 3.4 mm and run M3 with
nuts instead.

**Making it look right:** the rails are a separate print, so no AMS or filament
change is needed — just print the plate in black and the two rails in orange.

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

**Measured off the part:** the cell — `103040`, so 10.0 × 30 × 40 mm, read
straight off the pouch label. It was the biggest guess in the project and it
was wrong in all three axes.

**Still guesses:** every remaining Z dimension.

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
