// ============================================================================
//  sled.scad  --  open mounting sled, no walls, no lid
//
//  Black hex-lightened plate + bolt-on burnt-orange side rails, exposed M3.
//  Same visual language as the ESP32 Cyberdeck Case concept: black structure,
//  orange armour, screws left showing, hardware on display.
//
//  Nothing here has to line up with a connector, so this part cannot be wrong
//  about port positions. It is what proves params.scad.
//
//    PART="plate"  the black deck            (print 1)
//    PART="rail"   one orange side rail      (print 2, mirror on the bed)
//    PART="all"    both, laid out for review
//    CHECK=1       interference test instead of geometry
// ============================================================================

include <params.scad>
$fn = 48;

PART  = "all";
CHECK = 0;

// --- structure --------------------------------------------------------------
PLATE_T   = 3.00;   // deck thickness
EDGE      = 10.00;  // board to plate edge; also the width the rails bolt into
GAP       = 4.00;   // between bays
CORNER_R  = 4.00;
CH        = 1.00;   // chamfer, top and bottom. This is what stops it reading
                    // as a 3D print -- a chamfered edge looks machined.

// --- retention --------------------------------------------------------------
CLIP_T    = 1.60;
CLIP_LEG  = 8.00;
CLIP_OVER = 1.50;
POST_OD   = 6.00;
TIE_W     = 4.20;
TIE_H     = 2.40;

// --- lightening -------------------------------------------------------------
HEX_R     = 3.00;   // circumradius
HEX_GAP   = 1.80;   // web between cells
HEX_CLEAR = 2.50;   // solid kept around every functional feature

// --- rails ------------------------------------------------------------------
RAIL_W    = 8.00;
RAIL_T    = 3.50;
RAIL_CH   = 1.00;

// --- engraving --------------------------------------------------------------
TITLE     = "POWER PACK";
MARK      = "v0.2";
LABEL_D   = 0.60;

// ============================================================================
//  DERIVED
// ============================================================================
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
TIE_OFF     = FIT + CLIP_T + TIE_W/2 + 0.8;

MHX = (MOD_L - MOD_HX)/2;   MHY = (MOD_W - MOD_HY)/2;
MOD_HOLES = [ [MOD_X0+MHX, MOD_Y0+MHY], [MOD_X1-MHX, MOD_Y0+MHY],
              [MOD_X0+MHX, MOD_Y1-MHY], [MOD_X1-MHX, MOD_Y1-MHY] ];

// three bolts a side, through the rails
RAIL_YS = [ RAIL_W/2 + 0.5, PY/2, PY - RAIL_W/2 - 0.5 ];
RAIL_X  = RAIL_W/2;
MOUNT_HOLES = [ for (y = RAIL_YS, x = [RAIL_X, PX - RAIL_X]) [x, y] ];

ESP_PADS = [ [ESP_X0, ESP_Y0], [ESP_X1-6, ESP_Y0],
             [ESP_X0, ESP_Y1-6], [ESP_X1-6, ESP_Y1-6] ];

// ============================================================================
//  2D
// ============================================================================
module plate_2d() {
    hull() for (x = [CORNER_R, PX-CORNER_R], y = [CORNER_R, PY-CORNER_R])
        translate([x, y]) circle(r = CORNER_R);
}

module rect_2d(x0, y0, x1, y1) {
    translate([x0, y0]) square([x1-x0, y1-y0]);
}

// A hex is placed only if the WHOLE cell fits the zone and clears every
// feature. Clipping hexes against a keepout instead leaves half-eaten
// slivers, which read as damage rather than design.
function clear_circles(cx, cy, list, m) =
    len(list) == 0 ? true
    : min([for (p = list) norm([cx - p[0], cy - p[1]])]) >= m;

function clear_rects(cx, cy, list, m) =
    len(list) == 0 ? true
    : min([for (r = list) max(r[0]-cx, cx-r[2], r[1]-cy, cy-r[3])]) >= m;

module hex_field(x0, y0, x1, y1, circles = [], rects = []) {
    sx = sqrt(3)*HEX_R + HEX_GAP;
    sy = 1.5*HEX_R + HEX_GAP*0.866;
    hx = HEX_R*cos(30);          // half width  across flats
    hy = HEX_R;                  // half height across vertices
    nx = floor((x1-x0) / sx);
    ny = floor((y1-y0) / sy);
    ox = x0 + ((x1-x0) - nx*sx)/2 + sx/2;
    oy = y0 + ((y1-y0) - ny*sy)/2 + sy/2;
    for (j = [0 : ny-1], i = [0 : nx-1]) {
        cx = ox + i*sx + (j%2 ? sx/2 : 0);
        cy = oy + j*sy;
        if (cx - hx >= x0 && cx + hx <= x1 && cy - hy >= y0 && cy + hy <= y1
            && clear_circles(cx, cy, circles, HEX_R + HEX_CLEAR)
            && clear_rects(cx, cy, rects,     HEX_R + HEX_CLEAR))
            translate([cx, cy]) rotate([0, 0, 30]) circle(r = HEX_R, $fn = 6);
    }
}

// Rough box around a centred label, so the field leaves it standing.
function label_box(cx, cy, str, size) =
    [cx - len(str)*size*0.36, cy - size*0.75,
     cx + len(str)*size*0.36, cy + size*0.75];

module lightening_2d() {
    // under the module: the board is up on four posts, so only the posts and
    // the engraving are sacred
    hex_field(MOD_X0, MOD_Y0, MOD_X1, MOD_Y1,
              circles = MOD_HOLES,
              rects   = [label_box(PX/2, (MOD_Y0+MOD_Y1)/2, "MODULE", 4)]);

    // under the ESP32: brackets sit outboard of the pocket, so only the four
    // corner pads and the engraving are in the way
    hex_field(ESP_X0, ESP_Y0, ESP_X1, ESP_Y1,
              rects = concat([for (p = ESP_PADS) [p[0], p[1], p[0]+6, p[1]+6]],
                             [label_box(PX/2, (ESP_Y0+ESP_Y1)/2, "ESP32", 4)]));

    // the cell bay is deliberately absent here -- the pouch lies flat and
    // needs continuous support. It gets the same pattern engraved instead,
    // see cell_engraving_2d(), so the panel still reads as one system.
}

module cell_engraving_2d() {
    hex_field(CELL_X0, CELL_Y0, CELL_X1, CELL_Y1,
              rects = [label_box(PX/2, (CELL_Y0+CELL_Y1)/2, "CELL", 4)]);
}

// ============================================================================
//  3D helpers
// ============================================================================
// A flat part chamfered top and bottom. Only valid for convex outlines --
// plate_2d and rail_2d both are.
module chamfered(h, ch) {
    hull() {
        linear_extrude(0.01)            offset(-ch) children();
        translate([0, 0, ch])
            linear_extrude(h - 2*ch)                children();
        translate([0, 0, h - 0.01])
            linear_extrude(0.01)        offset(-ch) children();
    }
}

module corner_clip(x, y, sx, sy, h) {
    ox = sx > 0 ? -CLIP_T   : 0;    // thickness sits outboard of the pocket
    oy = sy > 0 ? -CLIP_T   : 0;
    lx = sx > 0 ? 0 : -CLIP_LEG;
    ly = sy > 0 ? 0 : -CLIP_LEG;
    translate([x, y, 0]) {
        translate([ox, ly, 0]) cube([CLIP_T,   CLIP_LEG, h]);
        translate([lx, oy, 0]) cube([CLIP_LEG, CLIP_T,   h]);
        translate([ox, oy, 0]) cube([CLIP_T,   CLIP_T,   h]);
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

module label_2d(x, y, s, size) {
    translate([x, y])
        text(s, size = size, halign = "center", valign = "center",
             font = "Helvetica:style=Bold");
}

module label(x, y, s, size) {
    translate([x, y, PLATE_T - LABEL_D])
        linear_extrude(LABEL_D + 1)
            text(s, size = size, halign = "center", valign = "center",
                 font = "Helvetica:style=Bold");
}

// ============================================================================
//  PLATE
// ============================================================================
module plate() {
    difference() {
        union() {
            chamfered(PLATE_T, CH) plate_2d();

            // module standoffs, lightly coned on top so the board drops on
            for (p = MOD_HOLES) translate([p[0], p[1], 0]) {
                cylinder(h = PLATE_T + MOD_UNDER - 0.6, d = POST_OD);
                translate([0, 0, PLATE_T + MOD_UNDER - 0.6])
                    cylinder(h = 0.6, d1 = POST_OD, d2 = POST_OD - 1.2);
            }

            for (p = ESP_PADS) translate([p[0], p[1], 0])
                cube([6, 6, PLATE_T + ESP_UNDER]);
            pocket_clips(ESP_X0,  ESP_Y0,  ESP_X1,  ESP_Y1,  ESP_CLIP_H);
            pocket_clips(CELL_X0, CELL_Y0, CELL_X1, CELL_Y1, CELL_CLIP_H);
        }

        translate([0, 0, -1]) linear_extrude(PLATE_T + 2) lightening_2d();
        translate([0, 0, PLATE_T - LABEL_D])
            linear_extrude(LABEL_D + 1) cell_engraving_2d();

        for (p = MOD_HOLES)
            translate([p[0], p[1], -1]) cylinder(h = PLATE_T + MOD_UNDER + 2, d = SCREW_PILOT);
        for (p = MOUNT_HOLES)
            translate([p[0], p[1], -1]) cylinder(h = PLATE_T + 2, d = SCREW_PILOT);

        for (y = [CELL_Y0 + CLIP_LEG + 2, CELL_Y1 - CLIP_LEG - 2],
             x = [CELL_X0 - TIE_OFF, CELL_X1 + TIE_OFF]) tie_slot(x, y);
        for (x = [ESP_X0 - TIE_OFF, ESP_X1 + TIE_OFF])
            tie_slot(x, (ESP_Y0 + ESP_Y1)/2);

        label(PX/2, (ESP_Y0  + ESP_Y1)/2,  "ESP32",  4);
        label(PX/2, (CELL_Y0 + CELL_Y1)/2, "CELL",   4);
        label(PX/2, (MOD_Y0  + MOD_Y1)/2,  "MODULE", 4);
        label(PX/2, 4.0,          TITLE, 5.0);
        label(PX/2, PY - EDGE/2, MARK,  4);
    }
}

// ============================================================================
//  RAIL  --  print two. They are mirror images, so rotate one 180 on the bed.
// ============================================================================
module rail_2d() {
    intersection() { plate_2d(); rect_2d(0, 0, RAIL_W, PY); }
}

module rail() {
    difference() {
        chamfered(RAIL_T, RAIL_CH) rail_2d();
        for (y = RAIL_YS) translate([RAIL_X, y, -1]) {
            cylinder(h = RAIL_T + 2, d = SCREW_CLEAR);
            translate([0, 0, RAIL_T + 1 - 1.6])
                cylinder(h = 1.7, d1 = SCREW_CLEAR, d2 = SCREW_CLEAR + 2.6);
        }
    }
}

// ============================================================================
//  Interference check. A correct sled produces nothing here.
// ============================================================================
CHK = FIT * 0.5;
module occupies(x0, y0, x1, y1, z0, z1) {
    translate([x0 - CHK, y0 - CHK, z0]) cube([x1-x0 + 2*CHK, y1-y0 + 2*CHK, z1-z0]);
}
module interference() {
    intersection() {
        plate();
        union() {
            occupies(ESP_X0, ESP_Y0, ESP_X1, ESP_Y1,
                     PLATE_T + ESP_UNDER + 0.01, PLATE_T + ESP_UNDER + ESP_T);
            occupies(CELL_X0, CELL_Y0, CELL_X1, CELL_Y1,
                     PLATE_T + 0.01, PLATE_T + CELL_T);
            occupies(MOD_X0, MOD_Y0, MOD_X1, MOD_Y1,
                     PLATE_T + MOD_UNDER + 0.01, PLATE_T + MOD_UNDER + MOD_T);
        }
    }
}

// ============================================================================
if      (CHECK == 1)      interference();
else if (PART == "plate") plate();
else if (PART == "rail")  rail();
else { plate(); translate([PX + 10, 0, 0]) rail(); }

echo(str("PLATE  ", PX, " x ", PY, " x ", PLATE_T, " mm"));
echo(str("RAIL   ", RAIL_W, " x ", PY, " x ", RAIL_T, " mm  (print 2)"));
echo(str("tallest feature  ", max(CELL_CLIP_H, ESP_CLIP_H), " mm"));
