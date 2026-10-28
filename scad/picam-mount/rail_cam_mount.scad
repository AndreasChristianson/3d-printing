// rail_cam_mount.scad
// Low "nozzle cam" mount for the Kobra Max: an I-beam post that bolts to the TOP of
// the right base 4040 with M3 T-nuts / T-bolts, a pan yoke, and a tilting camera
// plate the board screws to. Replaces the slide-in mast + friction-fit fork.
//
// Coordinates mirror poop-chute/kobra_poop_env.scad onto the right rail:
//   X = printer X. The bed's RIGHT edge is x=0; outboard (toward the 4040) is +X.
//   Y = front/back. y=0 is the FRONT face of the X gantry's 2020; the printer front
//       is -Y. The nozzle's Y line is fixed (bed-slinger), so a camera aimed along
//       that line sees the nozzle wherever X is.
//   Z = up. The table is z=0.
//
// Parts (all M3 except the board):
//   - post:  base plate (4 x M3 into the rail's top slots) + I-beam post + stem.
//            Each I-beam channel has lips, so the ribbon snaps in on either side.
//   - yoke:  split ring over the stem (pan, clamped by an M3 pinch screw into a
//            heat-set insert) with two arms (tilt, M3 bolt into an insert in one arm).
//   - plate: camera plate with standoff bars for M2 self-tappers (holes go right
//            through), and a knuckle behind it between the yoke arms.
// The board mounts connector-DOWN (as in the old holder, so no image flip): the
// ribbon drops straight down in front of the yoke and post.
// Board footprint is the official 25 x 23.86 / 21 x 12.5 M2 pattern (Cam v1.3, v2 and
// v3 share it; the user's IMX219 measured 24.7 x 23.6).
//
// Print, no supports: post upright on its base; yoke upright on the ring; plate
// standing on its bottom edge (mode="plate" lays it out that way).
//
// Renders:
//   fit:   openscad -o fit_iso.png --imgsize=1200,900 --colorscheme=Tomorrow \
//            --camera=300,-420,330,-120,-60,110 rail_cam_mount.scad
//   STLs:  openscad -D 'mode="post"'  -o rail_cam_post.stl  rail_cam_mount.scad
//          openscad -D 'mode="yoke"'  -o rail_cam_yoke.stl  rail_cam_mount.scad
//          openscad -D 'mode="plate"' -o rail_cam_plate.stl rail_cam_mount.scad

use <picam3_module.scad>

mode = "fit";   // "fit" = mount on the printer, "post" / "yoke" / "plate" = printable parts
$fn = 48;

/* ---------- Printer (measured) ---------- */
rail_top_z       = 58;
bed_above_rail   = 73;     // right rail -> bed top surface (2026-10-17)
gantry_above_bed = 32;     // bed top -> gantry bottom at Z=0
rail_w           = 40;
slot_c           = [10, 30];   // slot centres from the rail's inboard face
nozzle_y         = -29;    // 21 in front of the X rail, which is 8 in front of the 2020
bed_top_z        = rail_top_z + bed_above_rail;   // 131

/* ---------- Assumed (CONFIRM) ---------- */
upright_y = 25;    // front face of the right Z upright (behind the gantry plates)
pi_back_y = upright_y - 150;   // back of the Pi case (150 in front of the upright)
th_front  = 40;    // toolhead (fans, LEDs) sticks out this far in front of the nozzle

/* ---------- Placement ---------- */
mount_y        = pi_back_y + 26;   // base plate centre; its front edge is just behind the Pi case
post_dy        = -8;               // post sits toward the front of the base, away from the toolhead
cam_y          = mount_y + post_dy;
post_x         = 30;   // post centre, outboard of the bed edge (board stays ~6 mm clear)
lens_above_bed = 12;   // lens centre above the bed surface
// Aim so the nozzle line from the bed edge (x=0) to the far side (x=-402) fills the
// view: the bisector of the two directions.
function dir(p) = atan2(-(p[0] - post_x), p[1] - cam_y);   // pan angle to a point
pan  = (dir([0, nozzle_y]) + dir([-402, nozzle_y])) / 2;
tilt = -2;

/* ---------- Hardware ---------- */
m3_clear = 3.4;
insert_d = 4.2;     // M3 x 4 deep x 5 OD heat-set insert
insert_l = 4.6;     // 4 mm insert + 0.6 for the bolt tip
m2_pilot = 1.7;     // M2 self-tapper

/* ---------- Edge treatment ---------- */
er = 1.0;           // edge radius on blocks

/* ---------- Post ---------- */
base_t   = 5;
base_w   = rail_w;  // across the rail (X); stays on top of the 4040 so it can slide past the Pi mount
base_l   = 50;      // along the rail (Y)
base_r   = 5;       // plan-view corner radius
bolt_dy  = 19;
// 3 bolts: the 4th (outboard slot, front) would sit under the post's flared foot
bolts    = [[slot_c[0], -bolt_dy], [slot_c[0], bolt_dy], [slot_c[1], bolt_dy]];
ib_w     = 14;      // I-beam flange width (X)
ib_d     = 23;      // I-beam overall depth (Y); 17 mm channel fits the 16 mm ribbon
ib_ft    = 2.4;     // flange thickness
ib_wt    = 2.4;     // web thickness
win_w    = 10;      // lightening windows through the web: width (Y)
win_gap  = 4;       // bar between the two windows
lip      = 2.5;     // ribbon lips, leaving a ~13 mm mouth
foot     = 3;       // flare at the bottom of the post
cap_t    = 3;
stem_d   = 10;
stem_h   = 9.5;

/* ---------- Yoke ---------- */
ring_h    = 10;
ring_od   = 20;
bore_d    = stem_d + 0.3;
slit      = 1.5;
ear_x     = [7, 17];   // pinch ears at +X (local)
ear_t_ins = 6.5;       // ear with the insert
ear_t     = 6;
knuckle_w = 6;
arm_gap   = knuckle_w + 0.6;
arm_t_ins = 5.5;       // arm with the insert
arm_t     = 5;
arm_r     = 5.5;
arm_rise  = 20;        // ring top -> tilt axis (tall, so the plate can tilt ~45 deg down)
arm_y     = [-6, 1];   // arm footprint on the ring, mostly behind the axis

/* ---------- Camera plate (local: tilt axis = X axis, camera looks +Y) ---------- */
knuckle_r   = 5.5;
ear_len     = 12;                   // tilt axis -> plate back face
plate_t     = 3;
plate_back  = ear_len;
plate_front = plate_back + plate_t;
standoff_h  = 4.5;                  // clears the 3.2 mm FPC connector behind the board
bar_w       = 4.2;
pcb_t       = 1.12;
pcb_w       = 25;
pcb_h       = 23.862;
pcb_back_y  = plate_front + standoff_h;
pcb_front_y = pcb_back_y + pcb_t;
lens_from_bottom = pcb_h - 14.4;    // connector-down: lens is 9.46 above the bottom edge
board_z0    = -lens_from_bottom;    // tilt axis at lens height
fpc_h       = 5.71;                 // connector band at the bottom edge
connector_w = 19.61;                // FPC connector width, centred on the board
bar_z0      = board_z0 + fpc_h + 0.7;
// M2 holes [x, z] in plate coords (connector-down = board rotated 180 deg)
holes = [for (h = [[2, 2], [23, 2], [2, 14.5], [23, 14.5]])
            [h[0] - pcb_w/2, board_z0 + pcb_h - h[1]]];

/* ---------- Derived ---------- */
tilt_z_rel = ring_h + arm_rise;                  // tilt axis above the shoulder
lens_z     = bed_top_z + lens_above_bed;
shoulder_z = lens_z - tilt_z_rel;
post_h     = shoulder_z - rail_top_z - base_t - cap_t;

echo(str("post_h=", post_h, " shoulder_z=", shoulder_z, " lens_z=", lens_z,
         " pan=", pan, " mount_y=", mount_y,
         " view to bed edge/far side=", dir([0, nozzle_y]), "/", dir([-402, nozzle_y])));

/* ================= Helpers ================= */

// Box with all edges rounded to r, from [0,0,0] to size. r is capped at half the
// smallest side, so a thin box never bulges past its size.
module rcube(size, r = er)
    let(rr = min(r, size[0]/2, size[1]/2, size[2]/2) - 0.001)
    hull() for (x = [rr, size[0] - rr], y = [rr, size[1] - rr], z = [rr, size[2] - rr])
        translate([x, y, z]) sphere(r = rr, $fn = 16);

// Cylinder along +Z with both ends chamfered by c.
module ccyl(d, h, c = er) {
    hull() {
        translate([0, 0, c]) cylinder(d = d, h = h - 2 * c);
        cylinder(d = d - 2 * c, h = h);
    }
}

// Ring along +Z with chamfered outer edges.
module cring(od, id, h, c = er)
    rotate_extrude() polygon([[id/2, 0], [od/2 - c, 0], [od/2, c], [od/2, h - c],
                              [od/2 - c, h], [id/2, h]]);

/* ================= Parts ================= */

// I-beam piece i: 0/1 = flanges (perpendicular to Y), 2 = web. grow widens it (foot).
module ib_piece(i, z0, h, grow = 0) {
    if (i < 2)
        translate([-ib_w/2 - grow, i == 1 ? ib_d/2 - ib_ft - grow : -ib_d/2 - grow, z0])
            rcube([ib_w + 2 * grow, ib_ft + 2 * grow, h]);
    else
        translate([-ib_wt/2 - grow, -ib_d/2 + 1, z0]) rcube([ib_wt + 2 * grow, ib_d - 2, h]);
}

module post_part() {
    top = base_t + post_h;
    difference() {
        union() {
            // base plate: rounded in plan, chamfered top edge
            hull() {
                linear_extrude(base_t - er) offset(r = base_r)
                    translate([base_r, -base_l/2 + base_r]) square([base_w - 2 * base_r, base_l - 2 * base_r]);
                linear_extrude(base_t) offset(r = base_r - er)
                    translate([base_r, -base_l/2 + base_r]) square([base_w - 2 * base_r, base_l - 2 * base_r]);
            }
            translate([post_x, post_dy, 0]) {
                // I-beam with a flared foot: each piece hulled with a wider, short copy
                for (i = [0 : 2]) {
                    hull() {
                        ib_piece(i, base_t - er, 2 * er + 0.5, foot);
                        ib_piece(i, base_t - er, 2 * foot + er, 0);
                    }
                    ib_piece(i, base_t - er, post_h + er + 0.5);
                }
                // ribbon lips at the channel mouths, both sides
                for (sx = [-1, 1], sy = [-1, 1])
                    translate([sx > 0 ? ib_w/2 - 1.6 : -ib_w/2, sy > 0 ? ib_d/2 - ib_ft - lip : -ib_d/2 + ib_ft - 0.01, base_t + foot * 2])
                        rcube([1.6, lip + 0.01, post_h - foot * 2 - 2], r = 0.6);
                // cap + stem
                translate([0, 0, top]) hull() {
                    translate([-ib_w/2, -ib_d/2, 0]) rcube([ib_w, ib_d, cap_t]);
                    ccyl(ring_od, cap_t);
                }
                translate([0, 0, top + cap_t - 0.01]) ccyl(stem_d, stem_h, 0.8);
            }
        }
        for (b = bolts) let(x = b[0], y = b[1])
            translate([x, y, -1]) cylinder(d = m3_clear, h = base_t + 2);
        // two lightening windows through the web, pointed top and bottom (45 deg,
        // so they print without support)
        z0 = base_t + 2 * foot + 3;
        win_h = (top - 3 - z0 - win_gap) / 2;
        for (k = [0, 1])
            translate([post_x, post_dy, z0 + k * (win_h + win_gap)]) web_window(win_h);
    }
}

module web_window(h) {
    a = win_w / 2;
    rotate([90, 0, 90]) linear_extrude(ib_wt + 2, center = true)
        offset(r = 1) offset(r = -1)
            polygon([[0, 0], [a, a], [a, h - a], [0, h], [-a, h - a], [-a, a]]);
}

module arm(x0, t) {
    hull() {
        translate([x0, arm_y[0], ring_h - er]) rcube([t, arm_y[1] - arm_y[0], 2]);
        translate([x0, 0, tilt_z_rel]) rotate([0, 90, 0]) ccyl(2 * arm_r, t, 0.8);
    }
}

module yoke_part() {
    ear_y0 = -slit/2 - ear_t_ins;
    ear_y1 = slit/2 + ear_t;
    bolt_x = (ear_x[0] + ear_x[1]) / 2 + 0.5;
    difference() {
        union() {
            cring(ring_od, bore_d, ring_h);
            translate([ear_x[0] - 2, ear_y0, 0]) rcube([ear_x[1] - ear_x[0] + 2, ear_y1 - ear_y0, ring_h]);
            arm(arm_gap/2, arm_t_ins);
            arm(-arm_gap/2 - arm_t, arm_t);
        }
        translate([0, 0, -1]) cylinder(d = bore_d, h = ring_h + 2);
        // pan slit + pinch screw (head on +Y, insert in the -Y ear)
        translate([bore_d/2 - 1, -slit/2, -1]) cube([ear_x[1], slit, ring_h + 2]);
        translate([bolt_x, 0, ring_h/2]) rotate([90, 0, 0]) {
            translate([0, 0, -ear_y1 - 1]) cylinder(d = m3_clear, h = 20);
            translate([0, 0, -ear_y0 - insert_l]) cylinder(d = insert_d, h = insert_l + 1);
        }
        // tilt bolt (head on -X, insert in the +X arm)
        translate([0, 0, tilt_z_rel]) rotate([0, 90, 0]) {
            translate([0, 0, -20]) cylinder(d = m3_clear, h = 40);
            translate([0, 0, arm_gap/2 + arm_t_ins - insert_l]) cylinder(d = insert_d, h = insert_l + 1);
        }
    }
}

// rcube with a sharp, flat bottom face: the face that sits on the print bed.
module fcube(size, r = er)
    hull() {
        rcube(size, r);
        cube([size[0], size[1], 0.01]);
    }

// The plate prints standing on its bottom edge (z = board_z0), so everything that
// starts there has a flat bottom, and nothing starts in mid-air.
module plate_part() {
    top = board_z0 + pcb_h;
    // The connector's latch spans nearly the whole board width, so nothing may sit
    // behind the board below bar_z0: the bars' lower legs run just outboard of it.
    leg_x0 = pcb_w/2 + 0.4;
    leg_w  = 2;
    half_w = leg_x0 + leg_w;
    bar_x  = pcb_w/2 - 2 - bar_w/2;  // bars' inner edges, centred on the M2 holes
    difference() {
        union() {
            // plate behind the board
            translate([-half_w, plate_back, board_z0]) fcube([2 * half_w, plate_t, pcb_h]);
            // knuckle fin back to the tilt axis, flat-bottomed
            hull() {
                translate([-knuckle_w/2, 0, 0]) rotate([0, 90, 0]) ccyl(2 * knuckle_r, knuckle_w, 0.8);
                translate([-knuckle_w/2, -knuckle_r, board_z0]) fcube([knuckle_w, 2, 2]);
                translate([-knuckle_w/2, plate_back - 1, board_z0]) fcube([knuckle_w, 2, top - board_z0 - 4]);
            }
            for (s = [-1, 1]) {
                // standoff bars above the connector band, reaching out past the board edge
                translate([s > 0 ? bar_x : -half_w, plate_front - er, bar_z0])
                    rcube([half_w - bar_x, standoff_h + er, top - bar_z0], r = 0.6);
                // ...and legs outboard of the board, down to the bed, so the bars don't start in mid-air
                translate([s > 0 ? leg_x0 : -half_w, plate_front - er, board_z0])
                    fcube([leg_w, standoff_h + er, bar_z0 - board_z0 + 2], r = 0.6);
            }
        }
        translate([-knuckle_w, 0, 0]) rotate([0, 90, 0]) cylinder(d = m3_clear, h = 2 * knuckle_w);
        // M2 holes right through the bars and the plate
        for (p = holes)
            translate([p[0], plate_back - 1, p[1]]) rotate([-90, 0, 0])
                cylinder(d = m2_pilot, h = plate_t + standoff_h + 2);
    }
}

module board() {
    // picam3_module: X across, Y up (connector at +Y), Z toward the scene.
    // rotate -90 about X: model Y -> -Z (connector down), model Z -> +Y (looks +Y).
    translate([-pcb_w/2, pcb_front_y, board_z0 + pcb_h]) rotate([-90, 0, 0]) picam3(true);
}

module fov(len = 450, h = 62.2, v = 48.8)   // IMX219
    color("Yellow", 0.12)
    translate([0, pcb_front_y + 7, 0]) hull() {
        cube(0.01, center = true);
        translate([0, len, 0]) cube([2 * len * tan(h/2), 0.01, 2 * len * tan(v/2)], center = true);
    }

/* ================= Printer context ================= */

module printer() {
    color("DimGray") translate([0, -420, rail_top_z - rail_w]) cube([rail_w, 720, rail_w]);
    color("DimGray") translate([0, upright_y, rail_top_z]) cube([20, 40, 300]);   // Z upright (assumed)
    color("WhiteSmoke") translate([rail_w, pi_back_y - 100, rail_top_z - 35]) cube([30, 100, 65]);   // Pi case
    color("DarkKhaki", 0.8) translate([-402, nozzle_y - 210, bed_top_z - 6]) cube([402, 420, 6]);
    color("Black", 0.6) translate([-450, 0, bed_top_z + gantry_above_bed]) cube([520, 20, 20]);
    // toolhead (rough block) at the right end of its travel
    color("Gainsboro", 0.6) translate([-30, nozzle_y - th_front, bed_top_z + 5]) cube([50, th_front + 29, 70]);
    color("Gold") translate([0, nozzle_y, bed_top_z]) cylinder(d1 = 0.5, d2 = 6, h = 5);
}

module assembly() {
    color("SteelBlue") translate([0, mount_y, rail_top_z]) post_part();
    translate([post_x, cam_y, shoulder_z]) rotate([0, 0, pan]) {
        color("DarkOrange") yoke_part();
        translate([0, 0, tilt_z_rel]) rotate([tilt, 0, 0]) {
            color("SteelBlue") plate_part();
            board();
            %fov();
        }
    }
}

if (mode == "fit") { printer(); assembly(); }
else if (mode == "asm") assembly();   // mount alone in printer coords, for clearance checks
else if (mode == "post")  post_part();
else if (mode == "yoke")  yoke_part();
else if (mode == "plate") translate([0, 0, -board_z0]) plate_part();
