// eero_ceiling_mount.scad
// Parametric ceiling mount for an eero Pro 6.
//
// SHAPE: the eero is a domed wedge — flat base 139x139 (r~34), tapering up to a
// smaller domed top (~135x132), with the BACK tapering hardest. The flat base is
// the widest, most rigid surface, so it's our capture feature.
//
// ORIENTATION (in use): base-UP against the ceiling, dome facing down into the
// room (LED stays visible, back wiring exits at the ceiling and routes up).
//
// RETENTION: snap tabs rooted at a top ring (near the dome end) hang DOWN and
// hook the base rim. Long lever arm => robust flex (unlike the stiff original).
// Four corner posts tie the ceiling plate to the top ring; the BACK is left open
// for wiring.
//
// MODEL / PRINT ORIENTATION: plate flat on the bed (z=0..plate_t), cage pointing
// up, eero inserts base-first down onto the plate. Flip it for installation.
//
// Preview:  openscad -o eero_ceiling_mount.png --render --viewall --autocenter \
//             --imgsize=950,850 --colorscheme=Tomorrow eero_ceiling_mount.scad
// STL:      openscad -o eero_ceiling_mount.stl eero_ceiling_mount.scad

$fn = 120;

/* ===================== eero Pro 6 (measured) ===================== */
// Footprint: X = side-to-side, Y = front(-Y)/back(+Y). Wiring exits the back (+Y).
base_x   = 139.1;   // base side-to-side
base_y   = 138.9;   // base front-to-back
base_r   = 34;      // base corner radius (derived from 168.3 mm diagonal)
top_x    = 135;     // top side-to-side
top_y    = 132;     // top front-to-back
top_r    = 30;      // top corner radius (est.)
eero_h   = 49.5;    // max device height (back middle); top surface is tilted/domed
// (The dome and the front/back tilt aren't modelled precisely — the mount only
//  contacts the base rim and guides the upper body, so they don't matter here.)

/* ===================== Fit & structure ===================== */
clr        = 0.5;   // clearance around the base, per side
wall       = 3.2;   // post / ring wall thickness
plate_t    = 4.0;   // ceiling plate thickness
cage_extra = 3.0;   // how far the cage rises past the eero top
post_span  = 40;    // corner-post footprint along each side (covers the corner arc)

/* ===================== Snap tabs ===================== */
tab_w        = 22;   // tab width
tab_t        = 2.6;  // tab thickness (this flexes)
tab_gap      = 0.6;  // clearance between tab inner face and the eero wall
catch_h      = 5;    // height of the hook catch above the base (into the undercut)
catch_reach  = 2.4;  // how far the hook reaches in over the base rim
catch_lip    = 3.0;  // vertical thickness of the hook

/* ===================== Ceiling mounting (drywall / screws) ===================== */
screw_d      = 4.5;  // #8 shank clearance
screw_head_d = 9.0;  // countersink head dia
screw_inset  = 14;   // screw hole inset from plate edge

/* ===================== Cable exit (back, +Y) ===================== */
cable_slot_w = 34;   // width of the back cable slot in the plate
cable_open_h = 26;   // how far up the back the cage stays open for wiring

/* ===================== Derived ===================== */
in_x   = base_x + 2*clr;          // cavity (base + clearance)
in_y   = base_y + 2*clr;
in_r   = base_r + clr;
out_x  = in_x + 2*wall;           // outer footprint
out_y  = in_y + 2*wall;
out_r  = in_r + wall;
cage_h = eero_h + cage_extra;     // height of cage above the plate
top_z  = plate_t + cage_h;        // top of cage / ring

/* ===================== Helpers ===================== */
module rrect(x, y, r) { offset(r = r) square([x - 2*r, y - 2*r], center = true); }

// Hollow rounded-rect tube, extruded h tall, sitting on z=0.
module tube(h) {
    linear_extrude(h) difference() { rrect(out_x, out_y, out_r); rrect(in_x, in_y, in_r); }
}

/* ===================== Reference eero (for fit checks; not exported) ===================== */
module ghost_eero() {
    translate([0, 0, plate_t])
        hull() {
            linear_extrude(0.1) rrect(base_x, base_y, base_r);
            translate([0, 0, eero_h - 0.1]) linear_extrude(0.1) rrect(top_x, top_y, top_r);
        }
}

/* ===================== Parts ===================== */

module ceiling_plate() {
    difference() {
        linear_extrude(plate_t) rrect(out_x, out_y, out_r);
        // countersunk screw holes
        px = out_x/2 - screw_inset;  py = out_y/2 - screw_inset;
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*px, sy*py, -0.1]) {
                cylinder(d = screw_d, h = plate_t + 0.2);
                translate([0,0,plate_t-2.4]) cylinder(d1 = screw_d, d2 = screw_head_d, h = 2.5);
            }
        // back cable slot (+Y edge)
        translate([0, out_y/2 - 6, plate_t/2])
            cube([cable_slot_w, 16, plate_t + 2], center = true);
    }
}

// Four corner posts: the cage tube, kept only at the corners.
module corner_posts() {
    intersection() {
        translate([0,0,plate_t]) tube(cage_h);
        for (sx = [-1,1], sy = [-1,1])
            translate([sx*(out_x/2 - post_span/2), sy*(out_y/2 - post_span/2), 0])
                cube([post_span, post_span, 2*top_z], center = true);
    }
}

// Continuous ring at the top tying the posts together (roots the tabs).
module top_ring() {
    translate([0, 0, top_z - wall]) tube(wall);
}

// One snap tab: rooted at the top ring, hanging down, hook at the bottom.
// Built on the +X side, then rotated into place by the caller.
module snap_tab_pos_x() {
    xi = in_x/2 + tab_gap;       // tab inner face (just outside the eero wall)
    xo = xi + tab_t;             // tab outer face
    z0 = plate_t + catch_h;      // bottom of tab / hook catch height
    union() {
        // flexing beam from the top ring down to the hook
        translate([xi, -tab_w/2, z0]) cube([tab_t, tab_w, top_z - z0]);
        // hook wedge: flat catch face on the bottom, ramp on top for snap-in
        hull() {
            translate([xi - catch_reach, -tab_w/2, z0]) cube([catch_reach + tab_t, tab_w, 0.8]);
            translate([xi, -tab_w/2, z0 + catch_lip]) cube([tab_t, tab_w, 0.8]);
        }
    }
}

module snap_tabs() {
    rotate([0,0,  0]) snap_tab_pos_x();   // right (+X)
    rotate([0,0,180]) snap_tab_pos_x();   // left  (-X)
    rotate([0,0,270]) snap_tab_pos_x();   // front (-Y)  (rotates +X tab onto -Y)
    // back (+Y) intentionally has NO tab — left open for wiring
}

/* ===================== Assembly ===================== */
module mount() {
    ceiling_plate();
    corner_posts();
    top_ring();
    snap_tabs();
}

mount();
// ghost_eero();   // uncomment to visualise the eero inside the cage
