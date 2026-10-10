// kobra_poop_env.scad
// Reference model of the space around the Kobra Max poop location, built from
// measured dimensions. This is the GROUND TRUTH the poop chute is designed around.
//
// Axes (printer X, world Y/Z):
//   X = printer X. The bed's left edge is at x=0; outboard (toward the 4040) is -X.
//   Y = front/back. y=0 is the FRONT face of the X gantry; the printer front is -Y.
//       The nozzle's Y line is fixed (bed-slinger), so the poop always falls at the
//       same world Y no matter where the bed is.
//   Z = up. The table is z=0.
//
// Preview:  openscad -o kobra_poop_env.png --render --imgsize=1200,900 \
//             --colorscheme=Tomorrow --camera=-260,-420,330,-20,-60,90 kobra_poop_env.scad

$fn = 48;

/* ---------- Measured (2026-10-09) ---------- */
rail_top_z      = 58;    // table -> top of the 4040
bed_above_rail  = 70;    // top of the 4040 -> bed top surface (read as vertical; CONFIRM)
bed_t           = 6;     // bed thickness
gantry_above_bed = 32;   // bed top -> bottom of the X gantry, at Z=0 ("ish")
poop_from_gantry = 50;   // poop -> front face of the X gantry, in Y
pin_out          = 35;   // cut pin bracket sticks this far forward of the gantry
pin_from_bed_edge = 33;  // cut pin is this far outboard of the bed's left edge

// Confirmed: 70 mm is vertical; the pin bracket is no lower than the gantry; the
// bed's POM wheel frame stays clear of the left edge. Slots take M3 T-nuts.

/* ---------- Assumed ---------- */
rail_gap   = 0;    // bed left edge -> inboard face of the 4040, in X (top-down photo: ~flush)
rail_w     = 40;   // 4040
slot_w     = 6;    // T-slot opening (fits M3 T-nuts; exact width unmeasured)
gantry_d   = 45;   // gantry depth in Y, behind its front face
gantry_h   = 40;
pin_blk    = [26, pin_out, 25];   // pin bracket block (x, y, z); bottom = gantry bottom
poop_y_spread = 15; // kick runs at Y=360 vs purge Y=345: the bed shifts the poop 15 mm
bed_y_len  = 420;  // bed plate length (Y)
bed_y_travel = 434; // Y travel (-10..424)

/* ---------- Derived ---------- */
bed_top_z    = rail_top_z + bed_above_rail;          // 128
gantry_bot_z = bed_top_z + gantry_above_bed;         // 160 at Z=0
rail_x0      = -rail_gap - rail_w;                   // outboard face of the 4040
poop_y       = -poop_from_gantry;
pin_x        = -pin_from_bed_edge;

module rail4040(len) {
    // 4040 extrusion with two slots per face, running along Y.
    difference() {
        cube([rail_w, len, rail_w]);
        for (c = [10, 30]) {
            // top + bottom slots
            translate([c - slot_w/2, -1, rail_w - 3]) cube([slot_w, len + 2, 4]);
            translate([c - slot_w/2, -1, -1])         cube([slot_w, len + 2, 4]);
            // side slots
            translate([-1, -1, c - slot_w/2])         cube([4, len + 2, slot_w]);
            translate([rail_w - 3, -1, c - slot_w/2]) cube([4, len + 2, slot_w]);
        }
    }
}

module env() {
    // table
    color("BurlyWood", 0.5) translate([-250, -350, -3]) cube([700, 650, 3]);

    // left base 4040 (feet under it)
    color("DimGray") translate([rail_x0, -320, rail_top_z - rail_w]) rail4040(560);
    color("Black") for (y = [-300, 220])
        translate([rail_x0 + rail_w/2, y, 0]) cylinder(d = 20, h = rail_top_z - rail_w);

    // bed plate, shown at one Y position, plus its swept envelope (ghost)
    color("Goldenrod") translate([0, -260, bed_top_z - bed_t]) cube([400, bed_y_len, bed_t]);
    %translate([0, -260 - bed_y_travel/2, bed_top_z - bed_t])
        cube([400, bed_y_len + bed_y_travel, bed_t]);

    // X gantry at Z=0 and the cut pin bracket hanging off its left end
    color("SlateGray") translate([-70, 0, gantry_bot_z]) cube([480, gantry_d, gantry_h]);
    color("Black") translate([pin_x - pin_blk[0]/2, -pin_out, gantry_bot_z]) cube(pin_blk);
    color("Silver") translate([pin_x, -pin_out + 6, gantry_bot_z - 4]) cylinder(d = 3, h = 30);

    // left Z upright (assumed 2040, standing on the 4040 behind the gantry face)
    color("DimGray") translate([rail_x0, gantry_d * 0.2, rail_top_z]) cube([rail_w, 20, 420]);

    // poop: where it forms (on the bed's left edge) and its fall zone off the edge
    color("Red") translate([-5, poop_y, bed_top_z + 6]) sphere(d = 12);
    color("Red", 0.25) translate([-35, poop_y - poop_y_spread - 10, rail_top_z])
        cube([35, 2 * poop_y_spread + 20, bed_top_z - rail_top_z]);
}

show_env = true;   // files that include this set it false and call env() themselves
if (show_env) env();
