// ============================================================================
//  params.scad  --  the only file with real-world measurements in it
//
//  Every other .scad file derives from these. Edit by hand, or run:
//      ./measure.sh
//  which walks you through each one and rewrites this file.
//
//  status:  M = measured with calipers      G = still a guess
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
CELL_L     = 50.00;   // G  \  assumed 503450. If the cell has a number
CELL_W     = 34.00;   // G   > printed on it, that number IS the size --
CELL_T     =  5.50;   // G  /  see the decoder in MEASURING.md
CELL_LEAD  = 60.00;   // G  usable length of the JST lead

// --- ESP32 dev board --------------------------------------------------------
ESP_L      = 51.00;   // G  from the Cyberdeck graybox fit basis
ESP_W      = 28.00;   // G
ESP_T      =  1.60;   // G
ESP_UNDER  =  3.00;   // G  solder tails / pin stubs under the board
ESP_OVER   =  6.00;   // G  bare board. With headers this is ~14.

// --- print + fastener preferences ------------------------------------------
FIT         =   0.50;   // M  clearance around each board
SCREW_PILOT =   2.50;   // M  M3 self-tapping pilot
SCREW_CLEAR =   3.40;   // M  M3 clearance hole
