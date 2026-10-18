// kobra_xmotor_env.scad
// Reference model of the space around the Kobra Max X motor / left Z carriage,
// where the AFC bowden passes on its way to the toolhead. This is the GROUND
// TRUTH the tube guide is designed around.
//
// Axes (printer X/Y, world Z):
//   X = printer X. +X is toward the bed (inboard); -X is outboard, toward the
//       BoxTurtle.
//   Y = front/back. -Y is the printer front.
//   Z = up.
//   Origin = centre of the tapped M3 hole, on the top face of the old runout-
//            sensor tab (stock Kobra Z carriage). Everything rides with the
//            carriage EXCEPT the leadscrew, which is fixed to the frame.
//
// Preview:  openscad -o env_iso.png --render --imgsize=1200,900 \
//             --colorscheme=Tomorrow --camera=0,0,10,60,0,215,330 kobra_xmotor_env.scad

$fn = 48;

/* ---------- Measured / stated (2026-10-17) ---------- */
tab_in_w      = 9.6;   // clear width between the two raised walls (Y)
wall_h        = 2.5;   // raised side walls, above the tab's top face
hole_edge_to_end = 7.3; // M3 hole edge -> free (outboard) end of the tab
wall_to_screw = 8;     // front tab wall -> Z leadscrew surface, in Y
screw_d       = 8;     // Z leadscrew
rise          = 40;    // wanted tube height above the tab (clear of the wire tangle)
tube_od       = 4;     // one continuous PTFE run, turtleneck -> toolhead
tube_id       = 2.5;   // 2.5 or 2 depending on stock
// Tab sticks straight out (-X) from the carriage, walls on its front/back
// edges, hole centred between them. Tube comes up from below (BoxTurtle,
// outboard + low), rises past here, loops high, and drops into the toolhead.

tab_len       = 14;    // length of the raised walls = free end -> gantry base plate (X)
screw_dx      = 38;    // leadscrew centre X relative to the hole (+ = inboard)
// Tube rises inboard: BoxTurtle (low, outboard) -> past the carriage -> loops
// above the gantry and toolhead -> down into the toolhead top. Its angle here
// changes with X: flatter with the toolhead far +X, steeper far -X.
tube_angle    = 45;    // nominal; the guide's clamp pivots to follow it
// Above the gantry base plate there's only a loose wire mass, nothing solid.
// The guide must not stick out past the X motor's outboard face (gets bumped).

/* ---------- ASSUMED from photos (CONFIRM) ---------- */
tap_d      = 2.5;  // tapped M3 hole
tab_wall_t = 1.5;  // wall thickness (sheet steel)
sheet_t    = 1.5;  // tab sheet thickness = M3 thread length available
plate_t    = 5;    // gantry base plate the tab is part of: top is ~level with the tab
nut_d      = 22;   // brass nut flange (moves with the carriage)
nut_top_z  = -4;   // top of the brass nut flange vs the tab top
upright_y1 = -30;  // back face of the 2040 Z upright (it's in front of the leadscrew)
// X motor (NEMA17, 42.3 square) sits further forward, below and outboard.
motor_top_z = -16;
motor_x0    = -56;  // motor's OUTBOARD face = the guide's -X limit
motor_y1    = -34; // motor's back face

/* ---------- Derived ---------- */
hole_from_end = hole_edge_to_end + tap_d / 2;   // 8.55
tab_out_w = tab_in_w + 2 * tab_wall_t;
tab_x0    = -hole_from_end;                     // free (outboard) end
tab_x1    = tab_x0 + tab_len;                   // gantry base plate edge
screw_y   = -(tab_out_w / 2 + wall_to_screw + screw_d / 2);

module tab() {
    // Bent sheet tongue with up-turned edges; the M3 hole is tapped.
    color("DimGray") difference() {
        union() {
            translate([tab_x0, -tab_out_w / 2, -sheet_t]) cube([tab_len, tab_out_w, sheet_t]);
            for (s = [-1, 1])
                translate([tab_x0, s * (tab_in_w / 2 + tab_wall_t / 2) - tab_wall_t / 2, -sheet_t])
                    cube([tab_len, tab_wall_t, sheet_t + wall_h]);
        }
        translate([0, 0, -5]) cylinder(d = tap_d, h = 10);
    }
}

module gantry_plate() {
    // Gantry base plate the tab sticks out of; only loose wires above it.
    color("Black", 0.8) translate([tab_x1, -40, -sheet_t]) cube([60, 70, plate_t]);
    %translate([tab_x1, -40, plate_t]) cube([60, 70, 50]);   // wire mass (soft)
}

module leadscrew() {
    // Fixed to the frame: present at EVERY height, so the guide can't reach over it.
    color("Silver") translate([screw_dx, screw_y, -80]) cylinder(d = screw_d, h = 200);
    color("Goldenrod") translate([screw_dx, screw_y, nut_top_z - 12]) cylinder(d = 10.2, h = 12);
    color("Goldenrod") translate([screw_dx, screw_y, nut_top_z - 3.5]) cylinder(d = nut_d, h = 3.5);
}

module upright() {
    color("DarkSlateGray", 0.6) translate([tab_x1 + 3, upright_y1 - 40, -150]) cube([20, 40, 300]);
}

module x_motor() {
    color("SteelBlue", 0.6)
        translate([motor_x0, motor_y1 - 42.3, motor_top_z - 42.3]) cube([42.3, 42.3, 42.3]);
}

module tube_path(p = [0, 0, rise], len = 160) {
    // Target run: a straight 45-deg line through the guide point p, rising
    // inboard. Below, it bends away to the BoxTurtle; above, into the loop.
    color("Red") translate(p) rotate([0, 90 - tube_angle, 0])
        translate([0, 0, -len / 2]) cylinder(d = tube_od, h = len);
}

module env() {
    tab();
    gantry_plate();
    leadscrew();
    upright();
    x_motor();
}

// Files that `include` this one set env_standalone = false to skip this scene.
env_standalone = true;
if (env_standalone) {
    env();
    tube_path();
}
