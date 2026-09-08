// ============================================================================
//  params.scad  --  the only file with real-world measurements in it
//
//  Every other .scad file derives from these. Edit by hand, or run:
//      ./measure.sh
//  which walks you through each one and rewrites this file.
//
//  status:  M = measured with calipers   D = datasheet   G = still a guess
//
//  Board is an ESP32-WROOM-32 DevKitC-V4 (38-pin, CP2102), the same one as
//  ~/Code/quadruped-r1 -- see that project's controller/docs/MEASUREMENTS.md
// ============================================================================

// --- NULLLAB LiPo module ----------------------------------------------------
MOD_L      = 56.00;   // M  long edge of the PCB                (listing photo)
MOD_W      = 40.00;   // M  short edge of the PCB               (listing photo)
MOD_HX     = 48.00;   // M  hole spacing, centre to centre, long axis
MOD_HY     = 32.00;   // M  hole spacing, centre to centre, short axis
MOD_HD     =  4.70;   // G  mounting hole diameter
MOD_T      =  1.60;   // G  PCB thickness
MOD_UNDER  =  3.00;   // G  longest solder tail poking out the back
MOD_OVER   =  9.50;   // G  tallest thing on top (USB-A shell)

// --- LiPo pouch cell --------------------------------------------------------
//  REAL CELL, read off the label 2026-09-07: JBC 103040PL, 3.7 V 1200 mAh.
//  The 6-digit number IS the size (MEASURING.md): 10.0 x 30 x 40 mm. The old
//  503450 assumption was wrong in all three axes -- see "Printed" in README.md.
CELL_L     = 40.00;   // M  was 50.00  (G, assumed 503450)
CELL_W     = 30.00;   // M  was 34.00  (G)
CELL_T     = 10.00;   // M  was  5.50  (G) -- nearly 2x the guess
CELL_LEAD  = 60.00;   // G  usable length of the JST lead

// --- ESP32 dev board --------------------------------------------------------
//  ESP32-WROOM-32 DevKitC-V4, 38-pin, CP2102. Same board as ~/Code/quadruped-r1;
//  footprint below matches that project's MEASUREMENTS.md row 17, which is the
//  Espressif DevKitC-32E datasheet nominal. Neither is caliper-verified yet.
ESP_L      = 54.40;   // D  long edge of the PCB                  (datasheet)
ESP_W      = 27.90;   // D  short edge of the PCB                 (datasheet)
ESP_T      =  1.60;   // G  PCB thickness
ESP_UNDER  =  3.00;   // M  Jesse confirmed 2026-09-06: underside is FLAT, no
                      //    downward breadboard pins. 3.00 is a safe over-
                      //    estimate of the clipped solder tails, so this is
                      //    no longer fit-critical - extra clearance is free.
ESP_OVER   =  6.00;   // G  bare board. With headers fitted ~14.

// --- print + fastener preferences ------------------------------------------
FIT         =   0.50;   // M  clearance around each board
SCREW_PILOT =   2.50;   // M  M3 self-tapping pilot
SCREW_CLEAR =   3.40;   // M  M3 clearance hole
