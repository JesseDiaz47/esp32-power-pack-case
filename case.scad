// ============================================================================
//  ESP32 Power Pack Case  --  v0.1 FIT TEST
//
//  Holds three things in one flat tray:
//    1. NULLLAB LiPo module  (USB-C in, USB-A + 3V3/5V out, 4-LED gauge)
//    2. a 1200 mAh LiPo pouch cell
//    3. an ESP32-WROOM-32 DevKitC-V4 (38-pin, 54.4 x 27.9 mm)
//
//  EVERY number marked [MEASURE] is a guess until calipers say otherwise.
//  Change the number, re-run build.sh. Nothing downstream is hardcoded.
// ============================================================================

part = "both";          // "base" | "lid" | "both"
$fn  = 48;

// --- NULLLAB LiPo module ----------------------------------------------------
MOD_L      = 56.0;      // from listing photo dimension
MOD_W      = 40.0;      // from listing photo dimension
MOD_HX     = 48.0;      // mounting hole spacing, long axis
MOD_HY     = 32.0;      // mounting hole spacing, short axis
MOD_T      = 1.60;      // [MEASURE] PCB thickness, assumed standard
MOD_UNDER  = 3.00;      // [MEASURE] solder-tail clearance below the PCB
MOD_OVER   = 9.50;      // [MEASURE] tallest thing on top (USB-A shell ~6.5)

// --- LiPo pouch cell (assumed 503450) ---------------------------------------
CELL_L     = 50.0;      // [MEASURE] biggest unknown in the whole design
CELL_W     = 34.0;      // [MEASURE]
CELL_T     =  5.5;      // [MEASURE]

// --- ESP32 dev board (from the Cyberdeck graybox fit basis) -----------------
ESP_L      = 51.0;      // [MEASURE] 38-pin USB-C board
ESP_W      = 28.0;      // [MEASURE]
ESP_T      =  1.60;
ESP_UNDER  =  3.00;     // solder-tail clearance
ESP_OVER   =  6.00;     // [MEASURE] bare board. Headers? raise to ~14.

// --- Shell ------------------------------------------------------------------
WALL       = 2.40;
FLOOR      = 2.00;
LID_T      = 2.40;
ROUT       = 4.00;      // outer corner radius
FIT        = 0.50;      // per-side clearance around boards
SIDE_PAD   = 6.00;      // wire room left/right of the widest board
BAY_GAP    = 4.00;      // open channel between bays (wire routing)
EDGE_GAP   = 1.00;      // board edge -> inner wall, at connector edges

// --- Fasteners --------------------------------------------------------------
BOSS_OD      = 5.60;    // lid screw boss
SCREW_PILOT  = 2.50;    // M3 self-tapping pilot
SCREW_CLEAR  = 3.40;    // M3 clearance in lid
CBORE_OD     = 6.00;    // counterbore for the head
CBORE_D      = 1.40;
POST_OD      = 6.00;    // module standoff
POST_PILOT   = 2.50;

// ============================================================================
//  DERIVED GEOMETRY  --  nothing below here needs hand editing
// ============================================================================
DECK   = max(MOD_UNDER, ESP_UNDER);      // common standoff height
IX     = MOD_L + 2*SIDE_PAD;             // inner width
IY     = EDGE_GAP + ESP_W + BAY_GAP + (CELL_W + 1.0) + BAY_GAP + MOD_W + EDGE_GAP;
OX     = IX + 2*WALL;
OY     = IY + 2*WALL;

MOD_TOP = FLOOR + DECK + MOD_T + MOD_OVER;
ESP_TOP = FLOOR + DECK + ESP_T + ESP_OVER;
BASE_H  = max(MOD_TOP, ESP_TOP) + 0.9;

// Bay origins, measured front (y=0) to back
ESP_Y0  = WALL + EDGE_GAP;                    ESP_Y1 = ESP_Y0 + ESP_W;
CELL_Y0 = ESP_Y1 + BAY_GAP;                   CELL_Y1 = CELL_Y0 + CELL_W + 1.0;
MOD_Y0  = CELL_Y1 + BAY_GAP;                  MOD_Y1 = MOD_Y0 + MOD_W;

MOD_X0  = WALL + SIDE_PAD;                    MOD_X1 = MOD_X0 + MOD_L;
ESP_X0  = (OX - ESP_L)/2;                     ESP_X1 = ESP_X0 + ESP_L;
CELL_X0 = (OX - CELL_L)/2;                    CELL_X1 = CELL_X0 + CELL_L;

PCB_Z   = FLOOR + DECK;                       // top face of both boards' seats
PCB_TOP = PCB_Z + MOD_T;

// Module mounting holes, centred on the 48 x 32 pattern
MHX = (MOD_L - MOD_HX)/2;   MHY = (MOD_W - MOD_HY)/2;
MOD_HOLES = [ [MOD_X0+MHX,         MOD_Y0+MHY],
              [MOD_X0+MOD_L-MHX,   MOD_Y0+MHY],
              [MOD_X0+MHX,         MOD_Y0+MOD_W-MHY],
              [MOD_X0+MOD_L-MHX,   MOD_Y0+MOD_W-MHY] ];

// Lid screws: front corners, mid gaps, back corners
BX = [WALL + 3.0, OX - WALL - 3.0];
BY = [WALL + 3.0, CELL_Y0 - BAY_GAP/2, OY - WALL - 3.0];
BOSSES = [ for (x = BX, y = BY) [x, y] ];

// --- Port positions, scaled off the listing photo ---------------------------
// [VERIFY] +/- ~1.5 mm. Cutouts are oversized to absorb that.
USBA_C  = MOD_X0 + 29.0;    USBA_W  = 16.0;   // USB-A, back edge of module
PORTW_C = MOD_Y1 - 21.0;    PORTW_L = 26.0;   // USB-C + ON/OFF switch, left wall
LED_X   = MOD_X0 + 6.7;                       // 4-LED gauge, seen through the lid
LED_Y0  = MOD_Y1 - 36.5;    LED_Y1  = MOD_Y1 - 25.0;

// ============================================================================
//  PRIMITIVES
// ============================================================================
module rrect(w, d, h, r) {
    hull() for (x = [r, w-r], y = [r, d-r]) translate([x, y, 0]) cylinder(h=h, r=r);
}

module slot(x0, y0, x1, y1, z0, z1) {
    translate([x0, y0, z0]) cube([x1-x0, y1-y0, z1-z0]);
}

// ============================================================================
//  BASE
// ============================================================================
module base() {
    difference() {
        union() {
            // shell
            difference() {
                rrect(OX, OY, BASE_H, ROUT);
                translate([WALL, WALL, FLOOR]) rrect(IX, IY, BASE_H, ROUT - WALL);
            }
            // lid screw bosses
            for (p = BOSSES)
                translate([p[0], p[1], FLOOR]) cylinder(h = BASE_H - FLOOR, d = BOSS_OD);

            // module standoffs
            for (p = MOD_HOLES)
                translate([p[0], p[1], FLOOR]) cylinder(h = DECK, d = POST_OD);

            // ESP32 end rails, with a lip to stop it sliding
            for (s = [0, 1]) {
                rx = s == 0 ? ESP_X0 - FIT : ESP_X1 + FIT - 3.0;
                slot(rx, ESP_Y0, rx + 3.0, ESP_Y1, FLOOR, FLOOR + DECK);
                lx = s == 0 ? ESP_X0 - FIT - 1.6 : ESP_X1 + FIT;
                slot(lx, ESP_Y0, lx + 1.6, ESP_Y1, FLOOR, FLOOR + DECK + 2.0);
            }

            // cell retaining ribs, sitting in the two gap bands
            slot(CELL_X0 - 2, CELL_Y0 - 1.6, CELL_X1 + 2, CELL_Y0,        FLOOR, FLOOR + 4.0);
            slot(CELL_X0 - 2, CELL_Y1,       CELL_X1 + 2, CELL_Y1 + 1.6,  FLOOR, FLOOR + 4.0);
        }

        // --- subtractions ---
        for (p = BOSSES)
            translate([p[0], p[1], FLOOR]) cylinder(h = BASE_H, d = SCREW_PILOT);
        for (p = MOD_HOLES)
            translate([p[0], p[1], FLOOR - 1]) cylinder(h = DECK + 2, d = POST_PILOT);

        // USB-A output, back wall
        slot(USBA_C - USBA_W/2, OY - WALL - 1, USBA_C + USBA_W/2, OY + 1,
             PCB_TOP - 0.6, PCB_TOP + MOD_OVER - 2.0);

        // USB-C charge input + ON/OFF switch, left wall (one window: the photo
        // puts them 12 mm apart, which leaves a rib too thin to print)
        slot(-1, PORTW_C - PORTW_L/2, WALL + 1, PORTW_C + PORTW_L/2,
             PCB_TOP - 0.8, PCB_TOP + 6.4);

        // ESP32 USB-C, front wall
        slot(OX/2 - 6.5, -1, OX/2 + 6.5, WALL + 1, PCB_Z - 0.8, PCB_Z + 5.4);

        // cell lead pass-through in the rear rib
        slot(CELL_X1 - 12, CELL_Y1 - 1, CELL_X1 - 6, CELL_Y1 + 2.6, FLOOR + 1.5, FLOOR + 5);
    }
}

// ============================================================================
//  LID
// ============================================================================
module lid() {
    difference() {
        rrect(OX, OY, LID_T, ROUT);

        for (p = BOSSES) {
            translate([p[0], p[1], -1])              cylinder(h = LID_T + 2, d = SCREW_CLEAR);
            translate([p[0], p[1], LID_T - CBORE_D]) cylinder(h = CBORE_D + 1, d = CBORE_OD);
        }

        // 4-LED battery gauge window
        translate([LED_X - 4, LED_Y0, -1]) rrect(8, LED_Y1 - LED_Y0, LID_T + 2, 2);

        // vents over the ESP32
        for (i = [0:4])
            translate([OX/2 - 17 + i*8, ESP_Y0 + 4, -1]) rrect(3.2, ESP_W - 8, LID_T + 2, 1.6);
        // vents over the module, clear of the LED window
        for (i = [0:4])
            translate([OX/2 - 13 + i*8, MOD_Y0 + 22, -1]) rrect(3.2, 14, LID_T + 2, 1.6);
    }
}

// ============================================================================
if (part == "base" || part == "both") base();
if (part == "lid"  || part == "both") translate([0, OY + 8, 0]) lid();

echo(str("OUTER  ", OX, " x ", OY, " x ", BASE_H + LID_T, " mm"));
echo(str("BASE_H ", BASE_H, "   DECK ", DECK, "   PCB_TOP ", PCB_TOP));
