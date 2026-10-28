// uc392.scad
// Reference model of the UC-392 CSI-to-HDMI adapter board (one of the two identical
// boards in the CSI-HDMI extension kit). Mounts are designed around this.
//
// Measured by the user with a micrometer (2026-10-21) unless marked (est); (est)
// values were scaled off photos.
//
// Axes (viewed from the front, the side with both sockets):
//   X = across the board, 0 = left edge (the P1 / A / B / C / GND pad row)
//   Y = along the board, 0 = HDMI end; the ribbon socket is at the far end (+Y)
//   Z = out of the front face; the PCB is z -1.5..0, the back is z < -1.5
//
// Preview:  openscad -o uc392.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow uc392.scad

$fn = 32;

/* ---------- Board ---------- */
uc_w = 24.77;    // X
uc_l = 27.6;     // Y
uc_t = 1.5;

// Holes: kit hardware is ~M1.7. The user gave edge GAPS (hole edge to board edge).
uc_hole_d   = 2.0;     // (est) M1.7 clearance
uc_hole_gap = 0.8;     // hole edge to the side / ribbon-end edges
uc_hole_mid = 12.3;    // middle holes: hole edge to the HDMI-end edge (CONFIRM which end)
uc_hx  = [uc_hole_gap + uc_hole_d/2, uc_w - uc_hole_gap - uc_hole_d/2];
uc_hy  = [uc_hole_mid + uc_hole_d/2, uc_l - uc_hole_gap - uc_hole_d/2];
uc_holes = [for (y = uc_hy, x = uc_hx) [x, y]];

/* ---------- Front ---------- */
// 15-pin FPC socket, centred, near the ribbon end; ribbon leaves the +Y edge
fpc_w  = 21.4;   // (est)
fpc_y0 = uc_l - 9.3;   // (est)
fpc_d  = 6.3;    // (est) along Y
fpc_h  = 2.5;
// HDMI type A receptacle, centred, sticking out past the HDMI end
hdmi_w     = 15;
hdmi_h     = 6.0;    // (est) standard type-A receptacle height
hdmi_l     = 13.0;   // (est) along Y, from its mouth
hdmi_out   = 1.0;    // (est) mouth past the board edge
hdmi_z0    = 0.5;    // "less than a mm" off the board

/* ---------- Back ---------- */
// The black jack (P3) on the back, at the ribbon end on the P1 side, overhanging that edge
jack_h   = 4.5;
jack_x   = [-0.8, 13.7];        // (est)
jack_y   = [uc_l - 11, uc_l - 3.6];   // (est) clear of the corner hole's riser

/* ---------- Kit riser (standoff) ---------- */
riser_h  = 6;
riser_af = 3.2;   // (est) across flats

// Accessors for files that `use` this one (variables don't cross `use`)
function uc392_size()    = [uc_w, uc_l, uc_t];
function uc392_holes()   = uc_holes;
function uc392_riser_h() = riser_h;
function uc392_fpc()     = [fpc_y0, fpc_d, fpc_h];   // socket start, depth along Y, height

module uc392(show_risers = true) {
    color("ForestGreen") translate([0, 0, -uc_t]) linear_extrude(uc_t) difference() {
        square([uc_w, uc_l]);
        for (h = uc_holes) translate(h) circle(d = uc_hole_d);
    }
    color("Silver") translate([(uc_w - fpc_w)/2, fpc_y0, 0]) cube([fpc_w, fpc_d, fpc_h]);
    color("Gold") translate([(uc_w - hdmi_w)/2, -hdmi_out, hdmi_z0]) cube([hdmi_w, hdmi_l, hdmi_h]);
    color("Black") translate([jack_x[0], jack_y[0], -uc_t - jack_h])
        cube([jack_x[1] - jack_x[0], jack_y[1] - jack_y[0], jack_h]);
    if (show_risers) color("Goldenrod") for (h = uc_holes)
        translate([h[0], h[1], -uc_t - riser_h]) cylinder(d = riser_af / cos(30), h = riser_h, $fn = 6);
}

// HDMI plug + cable boot, for clearance checks (standard type A plug, est)
module uc392_hdmi_plug(len = 40)
    color("DimGray") translate([(uc_w - 21)/2, -hdmi_out - len, hdmi_z0 + hdmi_h/2 - 5.5]) cube([21, len, 11]);

// 15-pin ribbon leaving the ribbon end
module uc392_ribbon(len = 20)
    color("Orange", 0.7) translate([(uc_w - 16)/2, fpc_y0 + fpc_d/2, fpc_h/2]) cube([16, fpc_d/2 + len, 0.3]);

uc392();
