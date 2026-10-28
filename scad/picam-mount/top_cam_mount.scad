// top_cam_mount.scad
// Bird's-eye camera mount for the Kobra Max, on the RIGHT end of the TOP 2020
// crossbar of the Z frame:
//   - bracket: wraps the crossbar: a top plate (2 x M3 T-nuts in the top slot, just
//     inboard of the existing slot screws, with a zip-tie tunnel between them) and a
//     front plate down the slotless front face, with a boss and a horizontal 10 mm
//     stem pointing straight out the front (along -Y).
//   - yoke:    the rail-cam yoke (rail_cam_mount.scad, reuse rail_cam_yoke.stl), clamped
//              on the stem: it swings about the stem (aims left/right) and its arms
//              reach forward to the tilt axis (aims front/back). Neither axis turns the
//              picture, so it stays square to the bed.
//   - pod:     the tilt part. The OV5647 hangs face-down under its plate and the top
//              UC-392 sits face-DOWN on top (component side toward the camera, to suit
//              the 60 mm ribbon's contacts), on the kit's risers, HDMI pointing back at
//              the crossbar. The ribbon folds round the plate's front edge, so swing and
//              tilt never move it; only the HDMI cable flexes. The plate is thick so the
//              plug, now under the board, still clears the yoke ring as it runs back over
//              the yoke and the bracket: zip-tie the cable through the bracket's tunnel.
//
// Printer coordinates (2026-10-21 measurements):
//   X = printer X. x=0 is the right face of the steel corner plate at the
//       crossbar's right end; inboard (left) is -X.
//   Y = front/back. y=0 is the FRONT face of the top 2020; the printer front is -Y.
//   Z = up. z=0 is the TOP face of the top 2020; the bed is 23 in (584.2) below.
//
// Hardware:
//   - bracket: 2 x M3 x 10 + T-nuts (or T-bolts).
//   - yoke:    as on the nozzle cam: M3 pinch screw + insert, M3 tilt bolt + insert.
//   - pod:     OV5647: 4 x M2 x 10 self-tappers through the board into the bosses
//              (bosses fit inside the board's copper keep-out rings; the board's back
//              has parts most of the way out to the holes). UC-392: the kit's M-F
//              nylon risers into the plate's top, kit nylon nuts slid into slots from
//              the plate's sides; the kit screws down through the board into the risers.
//
// Print, no supports: bracket upside down (its flat top on the bed; the stem's top is
// flattened to sit on the bed too); pod upside down (the UC-392 face on the bed).
// mode="bracket"/"pod" lay them out that way.
//
// Renders:
//   fit:   openscad -o top_fit.png --imgsize=1200,900 --colorscheme=Tomorrow \
//            --camera=-150,-120,-250,65,0,30,1400 top_cam_mount.scad
//   STLs:  openscad -D 'mode="bracket"' -o top_cam_bracket.stl top_cam_mount.scad
//          openscad -D 'mode="pod"'     -o top_cam_pod.stl     top_cam_mount.scad

use <rail_cam_mount.scad>   // yoke_part, rcube, ccyl
use <picam3_module.scad>
use <uc392.scad>

mode = "fit";   // "fit" = on the printer, "asm" = mount only, "bracket" / "pod" = printable parts
$fn = 48;

/* ---------- Printer (measured 2026-10-21) ---------- */
beam_w        = 20;       // top crossbar 2020
bed_top_z     = -23 * 25.4;
rail_front_y  = -34;      // front of the X linear rail
nozzle_y      = rail_front_y - 21;   // 21 in front of the rail (2026-10-17)
slot_screw_x  = -40;      // the existing screws in the crossbar's top slot
pulley_top_z  = -17.5;    // Z-sync pulley block behind the crossbar
pulley_back_y = 45;

/* ---------- Assumed (CONFIRM) ---------- */
bed_w    = 402;
bed_d    = 420;
bed_cx   = -224;   // bed centre X: bed's right edge ~23 inboard of the corner plate face
steel_t  = 3;      // corner plate thickness

/* ---------- Hardware ---------- */
m3_clear = 3.4;
m3_head  = 6.5;
insert_d = 4.2;    // M3 x 4 deep x 5 OD heat-set insert
insert_l = 4.6;
m2_pilot = 1.7;    // M2 self-tapper
riser_thread = 2.4;   // kit nylon riser's male thread, clearance
riser_nut    = 4.1;   // kit nylon nut: 3.8 across flats (measured) + clearance

/* ---------- Bracket ---------- */
top_t   = 6;             // top plate; its top face is the yoke's shoulder
stem_x  = -72;
base_x  = [stem_x - 20, stem_x + 20];   // clear of the slot screws at x=-40
bolt_x  = [stem_x - 12, stem_x + 12];
front_t = 5;             // front plate, down the crossbar's front face
front_h = 16;            // below the crossbar top
boss_y  = -42;           // boss front face: the yoke ring's shoulder (was -12; +30 mast 2026-10-28)
mast_h  = 12;            // boss height at its front end; full front_h + top_t at the root
root_w  = 24;            // boss width
stem_d  = 10;            // yoke bore is 10.3
stem_l  = 9.5;           // yoke ring is 10 long
stem_z  = top_t - stem_d/2 + 0.4;   // stem axis; its top is shaved flat at top_t for printing
tie_w   = 4.5;           // zip-tie tunnel between the T-nut holes
tie_h   = 2.2;
er      = 1.0;

// Yoke constants, copied from rail_cam_mount.scad (variables don't cross `use`)
tilt_z_rel = 30;         // shoulder -> tilt axis
knuckle_w  = 6;          // fits the yoke's 6.6 arm gap

/* ---------- Pod (local: tilt axis = X, forward = +Y, up = +Z; camera looks -Z) ---------- */
knuckle_r = 7;
pod_l     = 22;          // tilt axis -> lens, forward
plate_bot = 0.5;
plate_top = 15.5;        // high, so the HDMI plug (under the face-down board) clears the yoke ring
plate_t   = plate_top - plate_bot;
boss_h    = 4.5;         // clears the 3.2 mm FPC connector on the board's back
boss_d    = 4.4;         // inside the 4.75 copper keep-out ring round each hole
pcb_t     = 1.12;
cam_back  = plate_bot - boss_h;
cam_front = cam_back - pcb_t;
uc_face   = plate_top + 6;   // kit risers; the UC-392's front face rests on them
hdmi_pocket = 1.5;           // the board's HDMI receptacle dips into the plate's top
riser_thread_l = 5;          // riser's male thread (measured)
riser_nut_h = 1.8 + 0.3;     // kit nylon nut 1.8 thick (measured)
riser_nut_z = plate_top - 2 - riser_nut_h;   // nut slot: 2 of plastic over it, the thread runs right through
plate_f   = pod_l + 23.86 - 14.4 + 1;   // front edge: 1 past the camera's connector edge
plate_x   = [-14, 14];
plate_y   = [pod_l - 15, plate_f];
uc_y0     = plate_f - 2.5 - 27.6;      // UC-392 HDMI end; its ribbon end is 2.5 inside the front edge

// OV5647 (picam3 model) in pod coords: connector edge forward (+Y), lens at (0, pod_l).
// model X -> -X, model Y -> +Y, model Z (scene) -> -Z
cam_m = [[-1, 0, 0, 12.5], [0, 1, 0, pod_l - 14.4], [0, 0, -1, cam_front], [0, 0, 0, 1]];
cam_holes = [for (h = [[2, 2], [23, 2], [2, 14.5], [23, 14.5]]) [12.5 - h[0], pod_l + h[1] - 14.4]];
// UC-392 in pod coords: model Y (toward ribbon) -> +Y, model X -> -X, face DOWN; HDMI points back (-Y)
function uc_pod(h) = [24.77/2 - h[0], uc_y0 + h[1]];

/* ---------- Derived ---------- */
// The pod's forward (+Y) points out the front (world -Y); world X = -pod X.
tilt_y = boss_y - tilt_z_rel;
lens_z = stem_z + cam_front - 7;
v      = [bed_cx - stem_x, nozzle_y - (tilt_y - pod_l), bed_top_z - lens_z];   // lens -> bed centre (mid travel)
swing  = atan2(-v[0], -v[2]);                        // about the stem (+ = inboard)
aim    = atan2(v[1], norm([v[0], v[2]]));            // about the tilt axis (+ = toward the back)

echo(str("swing=", swing, " aim=", aim, " lens ", lens_z - bed_top_z, " above the bed"));

/* ================= Bracket ================= */

module bracket() {
    bw = base_x[1] - base_x[0];
    difference() {
        union() {
            // top plate + front plate, wrapping the crossbar's front-top edge
            translate([base_x[0], 0, 0]) rcube([bw, beam_w, top_t]);
            translate([base_x[0], -front_t, -front_h]) rcube([bw, front_t + 1, front_h + top_t]);
            // boss, and the stem straight out its front, top shaved flat
            hull() {
                translate([stem_x - root_w/2, -front_t - 10, -front_h]) rcube([root_w, 11, front_h + top_t]);
                translate([stem_x - root_w/2, boss_y, top_t - mast_h]) rcube([root_w, 10, mast_h]);
            }
            intersection() {
                translate([stem_x, boss_y + 1, stem_z]) rotate([90, 0, 0]) ccyl(stem_d, stem_l + 1, 0.8);
                translate([stem_x - stem_d, boss_y - 2 * stem_l, -front_h]) cube([2 * stem_d, 2 * stem_l, front_h + top_t]);
            }
        }
        for (x = bolt_x) translate([x, beam_w/2, -1]) {
            cylinder(d = m3_clear, h = top_t + 2);
            translate([0, 0, top_t - 1.5 + 1]) cylinder(d = m3_head, h = 5);
        }
        // zip-tie tunnel between the T-nut holes, front to back under the top face
        translate([stem_x - tie_w/2, 0, 0]) {
            for (y = [2.5, beam_w - 2.5 - tie_h]) translate([0, y, 1.5]) cube([tie_w, tie_h, top_t]);
            translate([0, 2.5, 1.5]) cube([tie_w, beam_w - 5, tie_h]);
        }
    }
}

/* ================= Pod ================= */

module pod() {
    difference() {
        union() {
            translate([plate_x[0], plate_y[0], plate_bot])
                rcube([plate_x[1] - plate_x[0], plate_y[1] - plate_y[0], plate_t]);
            // knuckle + tongue out to the plate
            hull() {
                translate([-knuckle_w/2, 0, 0]) rotate([0, 90, 0]) ccyl(2 * knuckle_r, knuckle_w, 0.8);
                translate([-knuckle_w/2, plate_y[0], plate_bot]) rcube([knuckle_w, 3, plate_t]);
            }
            // camera bosses
            for (p = cam_holes) translate([p[0], p[1], cam_back]) cylinder(d = boss_d, h = boss_h + 0.5);
        }
        translate([-knuckle_w, 0, 0]) rotate([0, 90, 0]) cylinder(d = m3_clear, h = 2 * knuckle_w);
        // M2 pilots right through bosses and plate
        for (p = cam_holes) translate([p[0], p[1], cam_back - 1]) cylinder(d = m2_pilot, h = boss_h + plate_t + 2);
        // UC-392 risers: thread down from the top, nut slid in from the plate's side
        for (h = uc392_holes()) let(p = uc_pod(h)) {
            translate([p[0], p[1], plate_top - riser_thread_l - 1]) cylinder(d = riser_thread, h = riser_thread_l + 2);
            hull() for (x = [p[0], sign(p[0]) * (plate_x[1] + 1)])
                translate([x, p[1], riser_nut_z]) cylinder(d = riser_nut / cos(30), h = riser_nut_h, $fn = 6);
        }
        // pocket for the HDMI receptacle, back of the plate
        translate([-9, plate_y[0] - 1, plate_top - hdmi_pocket]) cube([18, uc_y0 + 13 - plate_y[0] + 1, hdmi_pocket + 1]);
    }
}

module pod_boards() {
    multmatrix(cam_m) picam3(true);
    translate([24.77/2, uc_y0, uc_face]) rotate([0, 180, 0]) { uc392(false); uc392_hdmi_plug(); }
    color("Goldenrod") for (h = uc392_holes()) let(p = uc_pod(h))
        translate([p[0], p[1], plate_top]) cylinder(d = 3.7, h = uc_face - plate_top, $fn = 6);
}

module fov(len = 600, h = 53.5, v = 41.4)   // OV5647: long axis along pod X (world X)
    color("Yellow", 0.10)
    translate([0, pod_l, cam_front - 7]) hull() {
        cube(0.01, center = true);
        translate([0, 0, -len]) cube([2 * len * tan(h/2), 2 * len * tan(v/2), 0.01], center = true);
    }

/* ================= Printer context ================= */

module printer(gantry_z = 150) {
    color("DimGray") translate([-500, 0, -beam_w]) cube([500 - steel_t, beam_w, beam_w]);
    color("Black") translate([-steel_t, -5, -60]) cube([steel_t, 60, 65]);
    color("Silver") translate([slot_screw_x, beam_w/2, 0]) cylinder(d = 6, h = 2.5);
    color("Black") translate([-45, beam_w, pulley_top_z - 20]) cube([40, pulley_back_y - beam_w, 20]);
    color("DarkKhaki", 0.8) translate([bed_cx - bed_w/2, nozzle_y - bed_d/2, bed_top_z - 6]) cube([bed_w, bed_d, 6]);
    gz = bed_top_z + gantry_z;
    color("Black", 0.6) translate([-480, rail_front_y, gz]) cube([480, 28, 20]);
    color("Gainsboro", 0.6) translate([bed_cx - 25, nozzle_y - 40, gz - 30]) cube([50, 60, 90]);
}

module assembly() {
    color("SteelBlue") bracket();
    translate([stem_x, boss_y, stem_z]) rotate([0, swing, 0]) {
        color("DarkOrange") rotate([90, 0, 0]) yoke_part();   // ring on the stem, arms forward
        translate([0, -tilt_z_rel, 0]) rotate([aim, 0, 0]) rotate([0, 0, 180]) {
            color("LightSteelBlue") pod();
            pod_boards();
            %fov();
        }
    }
}

if (mode == "fit") { printer(); assembly(); }
else if (mode == "asm") assembly();
else if (mode == "bracket") translate([-stem_x, 0, top_t]) mirror([0, 0, 1]) bracket();
else if (mode == "pod") translate([0, 0, plate_top]) mirror([0, 0, 1]) pod();
