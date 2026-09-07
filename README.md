# ESP32 Power Pack Case

A single flat tray + lid holding the **NULLLAB LiPo module** (1200 mAh, USB‑C in,
USB‑A + 3V3/5V out, 4‑LED gauge), its **LiPo pouch cell**, and Jesse's **38‑pin
USB‑C ESP32** board.

**Status: v0.1 fit test.** Print it, check the fit, change numbers, re-run. It is
not validated hardware.

## Current size

| | mm |
|---|---:|
| Base | 72.8 × 117.8 × 17.0 |
| Lid | 72.8 × 117.8 × 2.4 |
| Assembled | 72.8 × 117.8 × 19.4 |

Both STLs render manifold (base genus 3, lid genus 17 — holes and vents).

## Layout

Three bays front → back, all on one level, no stacking:

```
  front wall ── ESP32 USB-C cutout
  ┌──────────────────────────────┐
  │  ESP32 51×28  on end rails   │
  ├─── open wire channel ────────┤
  │  LiPo cell 50×34  in ribs    │
  ├─── open wire channel ────────┤
  │  NULLLAB module 56×40        │  ← USB-C + switch out the LEFT wall
  └──────────────────────────────┘  ← USB-A out the BACK wall
```

Bays are open to each other so wires route freely. The 4‑LED gauge reads through
a window in the lid.

## Where the numbers came from

**Solid — read straight off the listing photo:**

| | mm |
|---|---:|
| Module PCB | 56.00 × 40.00 |
| Mounting hole pattern | 48.00 × 32.00 |
| Hole diameter | 4.70 (the photo's third callout) |

**Guessed — marked `[MEASURE]` in `case.scad`:**

| Parameter | Assumed | Why it's a guess |
|---|---:|---|
| `CELL_L/W/T` | 50 × 34 × 5.5 | **Biggest unknown.** The photo dimensions the *module*, not the cell. 503450 is the common 1200 mAh pouch. |
| `MOD_OVER` | 9.5 | Tallest part on top. USB‑A shell is ~6.5, JST ~6. No Z data in the photo. |
| `MOD_T` | 1.6 | Standard PCB, assumed. |
| `MOD_UNDER` | 3.0 | Solder-tail clearance under the module. |
| `ESP_L/W` | 51 × 28 | From the ESP32 Cyberdeck Case graybox fit basis. |
| `ESP_OVER` | 6.0 | Bare board. **Raise to ~14 if you're using headers.** |

**Port X/Y positions** (`USBA_C`, `PORTW_C`, `LED_X/Y`) were scaled off the
listing photo at ~7.4 px/mm, so carry roughly ±1.5 mm. Every cutout is
deliberately oversized to absorb that.

Two known consequences of that uncertainty:

- The USB‑C and ON/OFF switch are ~12 mm apart on the module's left edge. Two
  separate cutouts would leave a 0.9 mm rib — too thin to print — so they are
  **one combined port window**.
- The USB‑A is cut as **edge‑facing**. If yours is a vertical up‑facing part,
  the cutout moves to the lid instead.

## Measure these five, then re-run

1. **Cell** L × W × T → `CELL_L`, `CELL_W`, `CELL_T`
2. **Tallest component on the module** (USB‑A shell) → `MOD_OVER`
3. **Module PCB thickness** → `MOD_T`
4. **ESP32 stack height** — bare or with headers → `ESP_OVER`
5. **Module left edge**: distance from the back edge to the USB‑C and to the
   switch → `PORTW_C`, `PORTW_L`

```bash
./build.sh
```

Everything else in `case.scad` is derived. Change a bay dimension and the shell,
bosses, standoffs and cutouts all move with it.

## Hardware

- 6 × M3 self-tapping screws, ~10–12 mm, lid → base (2.5 mm pilots, 3.4 mm
  clearance + counterbore in the lid)
- 4 × M3 screws, ~6 mm, module → standoffs (works whether the board holes are
  3.2 or 4.7 mm — the head retains either way)

## Print notes

- Base prints flat on its floor, **no supports**. The wall cutouts bridge over a
  16 mm span at most.
- Lid prints flat.
- 0.2 mm layers, 3 perimeters, 20% infill is plenty.

## Before calling it final

1. Print the base only and dry-fit all three parts before printing the lid.
2. Confirm USB‑C **cable body** clearance, not just the connector.
3. Confirm the cell's JST lead actually reaches the module's back-edge connector
   — it's ~45 mm of routing. If the lead is short, swap the `ESP32` and `cell`
   bay order.
4. Confirm the USB‑A is edge-facing, not vertical.
5. Add strain relief or a retention pad over the cell before trusting it to move
   around.
