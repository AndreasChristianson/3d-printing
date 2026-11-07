// revo_nozzle.scad
// Reference model of an E3D Revo nozzle (standard or High Flow: same outside
// envelope), with its colour-coded silicone cuff. The GROUND TRUTH that the
// nozzle case is designed around.
//
// Axes: Z = nozzle axis, 0 = tip, + toward the threaded heat-break end.
//
// Sources (2026-11-07):
//  - E3D brass nozzle drawing, e3d-online.com/pages/revo-support-brass-nozzle
//    ("Volumes & Dimensions"): 41.1 overall, cuff OD 13, seal flange
//    22.8 +/-0.2 from the tip, 2 bore. Other sizes below are scaled off the
//    drawing (+/-0.2).
//  - E3D "Dummy Revo Six" reference STEP (printables.com/model/717699):
//    cuff band 13.00 OD x 5.17, tip ~2 below it. Agrees with the drawing.
//  - Cuff ID 10: measured by the user.
//
// Preview:  openscad -o revo_nozzle.png --render --viewall --autocenter \
//             --imgsize=900,900 --colorscheme=Tomorrow revo_nozzle.scad

$fn = 64;

/* ---------- Dimensions ---------- */
revo_len    = 41.1;   // tip to heat-break end

tip_len     = 2.2;    // conical tip below the cuff
tip_d0      = 1.0;    // tip flat
tip_d1      = 4.0;    // tip cone at the cuff face

cuff_od     = 13.0;   // silicone cuff: the widest part
cuff_id     = 10.0;   // (measured) the brass it grips
cuff_h      = 4.8;
cuff_z0     = tip_len;
cuff_z1     = cuff_z0 + cuff_h;   // 7.0
cuff_chamfer = 0.5;

body_d      = 6.0;    // brass body inside the HeaterCore
body_z1     = 19.5;
neck_d      = 2.6;
flange_d    = 6.0;    // seal flange
flange_z    = 22.8;   // its top face, from the tip (E3D toleranced dim)
flange_t    = 1.0;
thread_d    = 4.0;    // thread into the heatsink
thread_z0   = 24.0;
thread_z1   = 34.0;
break_d     = 3.0;    // heat-break tube to the end

/* ---------- Derived (used by the case) ---------- */
stem_len = revo_len - cuff_z1;   // 34.1: everything above the cuff
stem_max_d = max(body_d, flange_d, thread_d);

module revo_cuff(c = "red") {
    color(c) difference() {
        hull() {
            cylinder(d = cuff_od - 2*cuff_chamfer, h = cuff_h);
            translate([0, 0, cuff_chamfer])
                cylinder(d = cuff_od, h = cuff_h - 2*cuff_chamfer);
        }
        translate([0, 0, -1]) cylinder(d = cuff_id, h = cuff_h + 2);
    }
}

module revo_nozzle(cuff_color = "red") {
    color("goldenrod") {
        cylinder(d1 = tip_d0, d2 = tip_d1, h = tip_len);
        translate([0, 0, cuff_z0]) cylinder(d = cuff_id, h = cuff_h);
        translate([0, 0, cuff_z1]) cylinder(d = body_d, h = body_z1 - cuff_z1);
        translate([0, 0, body_z1]) cylinder(d = neck_d, h = thread_z0 - body_z1);
        translate([0, 0, flange_z - flange_t]) cylinder(d = flange_d, h = flange_t);
        translate([0, 0, thread_z0]) cylinder(d = thread_d, h = thread_z1 - thread_z0);
        translate([0, 0, thread_z1]) cylinder(d = break_d, h = revo_len - thread_z1);
    }
    translate([0, 0, cuff_z0]) revo_cuff(cuff_color);
}

show_revo_nozzle = true;   // a file that includes this one sets it false
if (show_revo_nozzle) revo_nozzle();
