// ============================================================================
//  sled.scad  --  Option D: open mounting sled, no walls, no lid
//
//  The point of this part is that NOTHING has to line up with a connector.
//  It cannot be wrong about port positions because it has no ports. Print it,
//  bolt the three parts down, and find out whether params.scad is true.
// ============================================================================

include <params.scad>
$fn = 48;

// --- sled-specific ----------------------------------------------------------
PLATE_T   = 3.00;   // plate thickness
EDGE      = 7.00;   // margin from board to plate edge
GAP       = 4.00;   // gap between bays
CORNER_R  = 4.00;
CLIP_T    = 1.60;   // retaining wall thickness
CLIP_LEG  = 8.00;   // how far each L leg runs
CLIP_OVER = 1.50;   // wall height above the board it retains
TIE_W     = 4.20;   // zip-tie slot
TIE_H     = 2.40;
POST_OD   = 6.00;
LABEL_D   = 0.60;   // engraving depth

// --- derived ----------------------------------------------------------------
PX = MOD_L + 2*EDGE;

ESP_Y0  = EDGE;              ESP_Y1  = ESP_Y0 + ESP_W;
CELL_Y0 = ESP_Y1 + GAP;      CELL_Y1 = CELL_Y0 + CELL_W;
MOD_Y0  = CELL_Y1 + GAP;     MOD_Y1  = MOD_Y0 + MOD_W;
PY = MOD_Y1 + EDGE;

MOD_X0  = EDGE;                  MOD_X1  = MOD_X0 + MOD_L;
ESP_X0  = (PX - ESP_L)/2;        ESP_X1  = ESP_X0 + ESP_L;
CELL_X0 = (PX - CELL_L)/2;       CELL_X1 = CELL_X0 + CELL_L;

CELL_CLIP_H = PLATE_T + CELL_T + CLIP_OVER;
ESP_CLIP_H  = PLATE_T + ESP_UNDER + ESP_T + CLIP_OVER;

MHX = (MOD_L - MOD_HX)/2;   MHY = (MOD_W - MOD_HY)/2;
MOD_HOLES = [ [MOD_X0+MHX,       MOD_Y0+MHY],
              [MOD_X1-MHX,       MOD_Y0+MHY],
              [MOD_X0+MHX,       MOD_Y1-MHY],
              [MOD_X1-MHX,       MOD_Y1-MHY] ];

MOUNT_HOLES = [ [4.5, 4.5], [PX-4.5, 4.5], [4.5, PY-4.5], [PX-4.5, PY-4.5] ];

// ============================================================================
module rrect(w, d, h, r) {
    hull() for (x = [r, w-r], y = [r, d-r]) translate([x, y, 0]) cylinder(h=h, r=r);
}

// One corner bracket. sx/sy are +1 or -1 and point into the pocket.
module corner_clip(x, y, sx, sy, h) {
    translate([x, y, 0]) {
        translate([sx > 0 ? 0 : -CLIP_T, sy > 0 ? 0 : -CLIP_LEG, 0])
            cube([CLIP_T, CLIP_LEG, h]);
        translate([sx > 0 ? 0 : -CLIP_LEG, sy > 0 ? 0 : -CLIP_T, 0])
            cube([CLIP_LEG, CLIP_T, h]);
    }
}

module pocket_clips(x0, y0, x1, y1, h) {
    corner_clip(x0-FIT, y0-FIT,  1,  1, h);
    corner_clip(x1+FIT, y0-FIT, -1,  1, h);
    corner_clip(x0-FIT, y1+FIT,  1, -1, h);
    corner_clip(x1+FIT, y1+FIT, -1, -1, h);
}

module tie_slot(x, y) {
    translate([x - TIE_W/2, y - TIE_H/2, -1]) cube([TIE_W, TIE_H, PLATE_T + 2]);
}

module label(x, y, s, size) {
    translate([x, y, PLATE_T - LABEL_D])
        linear_extrude(LABEL_D + 1)
            text(s, size = size, halign = "center", valign = "center",
                 font = "Helvetica:style=Bold");
}

// ============================================================================
module sled() {
    difference() {
        union() {
            rrect(PX, PY, PLATE_T, CORNER_R);

            // module: four standoffs on the 48 x 32 pattern
            for (p = MOD_HOLES)
                translate([p[0], p[1], 0]) cylinder(h = PLATE_T + MOD_UNDER, d = POST_OD);

            // ESP32: corner pads to sit on, plus corner brackets to locate it
            for (p = [[ESP_X0, ESP_Y0], [ESP_X1-6, ESP_Y0],
                      [ESP_X0, ESP_Y1-6], [ESP_X1-6, ESP_Y1-6]])
                translate([p[0], p[1], 0]) cube([6, 6, PLATE_T + ESP_UNDER]);
            pocket_clips(ESP_X0, ESP_Y0, ESP_X1, ESP_Y1, ESP_CLIP_H);

            // cell: brackets only, it lies flat on the plate
            pocket_clips(CELL_X0, CELL_Y0, CELL_X1, CELL_Y1, CELL_CLIP_H);
        }

        // module screw pilots
        for (p = MOD_HOLES)
            translate([p[0], p[1], -1]) cylinder(h = PLATE_T + MOD_UNDER + 2, d = SCREW_PILOT);

        // sled mounting holes, for bolting this to something later
        for (p = MOUNT_HOLES)
            translate([p[0], p[1], -1]) cylinder(h = PLATE_T + 2, d = SCREW_CLEAR);

        // zip-tie slots: two straps over the cell, one over the ESP32
        for (y = [CELL_Y0 + 8, CELL_Y1 - 8])
            for (x = [CELL_X0 - 3, CELL_X1 + 3]) tie_slot(x, y);
        for (x = [ESP_X0 - 3, ESP_X1 + 3]) tie_slot(x, (ESP_Y0 + ESP_Y1)/2);

        // engraved bay labels, readable during the dry fit
        label(PX/2, (ESP_Y0  + ESP_Y1)/2,  "ESP32",  6);
        label(PX/2, (CELL_Y0 + CELL_Y1)/2, "CELL",   6);
        label(PX/2, (MOD_Y0  + MOD_Y1)/2,  "MODULE", 6);
        label(PX/2, PY - 3.4, "v0.1 FIT TEST", 3);
    }
}

sled();

echo(str("SLED plate  ", PX, " x ", PY, " x ", PLATE_T, " mm"));
echo(str("tallest printed feature  ", max(CELL_CLIP_H, ESP_CLIP_H), " mm"));
echo(str("assembled envelope  ", PX, " x ", PY, " x ",
         PLATE_T + MOD_UNDER + MOD_T + MOD_OVER, " mm"));
