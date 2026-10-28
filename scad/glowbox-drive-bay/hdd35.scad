// hdd35.scad
// Reference model of a 3.5" hard drive (SFF-8300 form factor). This is the
// GROUND TRUTH the drive carrier and rails are designed around.
//
// Drive's own axes (as it lies flat, label up):
//   X = width (101.6). Y = length; Y=0 is the FRONT end (no connectors),
//   +Y runs toward the SATA connectors. Z = thickness; Z=0 is the BASE
//   (PCB side), the label is on the top cover at Z = hdd_h.
//
// Side mounting holes (6-32 UNC) are on the two long side faces (X=0 and
// X=hdd_w). Only the outer pair is used: Western Digital's 2018 white paper
// "3.5-inch Form Factor Mounting Screw Locations and Depths" says the middle
// hole is legacy and missing on some high-capacity drives. Positions are the
// SFF-8300 values; CONFIRM with calipers on a real drive before relying on the
// rail fit.
//
// Preview:  openscad -o hdd_iso.png --render --imgsize=1000,800 \
//             --colorscheme=Tomorrow hdd35.scad

$fn = 32;

/* ---------- SFF-8300 nominal ---------- */
hdd_l = 147.0;           // max length
hdd_w = 101.6;
hdd_h = 26.1;            // max height
hdd_side_hole_y  = [28.5, 130.1];  // from the front end; 101.6 apart
hdd_side_hole_y_legacy = 70.1;     // middle hole, not on every drive
hdd_side_hole_z  = 6.35; // above the base
hdd_tap_d        = 3.5;  // 6-32 UNC major diameter (modelled as a plain hole)
hdd_tap_depth    = 3.0;  // SFF-8300 only guarantees 3.02 mm screw penetration

// SATA connectors on the back end, for clearance checks only.
sata_x0 = 12;  sata_w = 36;  sata_h = 9;  sata_z0 = 1;

module hdd35(legacy_hole = false) {
    ys = legacy_hole ? concat(hdd_side_hole_y, [hdd_side_hole_y_legacy])
                     : hdd_side_hole_y;
    difference() {
        cube([hdd_w, hdd_l, hdd_h]);
        for (y = ys, x = [0, hdd_w])
            translate([x, y, hdd_side_hole_z])
                rotate([0, 90, 0])
                    cylinder(d = hdd_tap_d, h = 2 * hdd_tap_depth, center = true);
    }
    // connector block, sticking out behind the drive
    translate([sata_x0, hdd_l, sata_z0]) cube([sata_w, 6, sata_h]);
}

// Demo when opened directly; files that include this set hdd_lib_only = true.
if (is_undef(hdd_lib_only)) hdd35(legacy_hole = true);
